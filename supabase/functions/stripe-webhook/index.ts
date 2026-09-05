// Supabase Edge Function: stripe-webhook
// Deploy:  supabase functions deploy stripe-webhook
// Env vars (Settings → Edge Functions → Secrets):
//   STRIPE_SECRET_KEY       — same key as create-checkout
//   STRIPE_WEBHOOK_SECRET   — whsec_... from Stripe dashboard webhook endpoint
//   SUPABASE_URL            — auto-provided
//   SUPABASE_SERVICE_ROLE_KEY — auto-provided
//
// Stripe dashboard setup:
//   Developers → Webhooks → Add endpoint
//   URL: https://<project-ref>.supabase.co/functions/v1/stripe-webhook
//   Events to listen for: checkout.session.completed

import Stripe from 'https://esm.sh/stripe@14.21.0?target=deno';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2?target=deno';

Deno.serve(async (req: Request) => {
  const body = await req.text();
  const sig  = req.headers.get('stripe-signature');

  if (!sig) return new Response('Missing stripe-signature header', { status: 400 });

  const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
    apiVersion: '2023-10-16',
  });

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(
      body, sig, Deno.env.get('STRIPE_WEBHOOK_SECRET')!,
    );
  } catch (err) {
    console.error('Webhook signature verification failed:', (err as Error).message);
    return new Response(`Webhook Error: ${(err as Error).message}`, { status: 400 });
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object as Stripe.Checkout.Session;

    if (session.payment_status === 'paid') {
      const supabase = createClient(
        Deno.env.get('SUPABASE_URL')!,
        Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      );

      const { error } = await supabase
        .from('room_payments')
        .update({
          status: 'paid',
          stripe_payment_intent_id: session.payment_intent as string,
        })
        .eq('stripe_session_id', session.id);

      if (error) console.error('Failed to update payment:', error.message);
    }
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
