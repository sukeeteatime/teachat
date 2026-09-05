// Supabase Edge Function: create-checkout
// Deploy:  supabase functions deploy create-checkout
// Env vars to set in Supabase dashboard (Settings → Edge Functions → Secrets):
//   STRIPE_SECRET_KEY      — your Stripe secret key (sk_live_... or sk_test_...)
//   SUPABASE_URL           — auto-provided
//   SUPABASE_ANON_KEY      — auto-provided
//   SUPABASE_SERVICE_ROLE_KEY — auto-provided

import Stripe from 'https://esm.sh/stripe@14.21.0?target=deno';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2?target=deno';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: cors });

  try {
    // Verify caller is a signed-in Supabase user
    const authHeader = req.headers.get('Authorization') ?? '';
    const supabaseAuth = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
    );
    const { data: { user }, error: authErr } = await supabaseAuth.auth.getUser(
      authHeader.replace('Bearer ', ''),
    );
    if (authErr || !user) {
      return new Response('Unauthorized', { status: 401, headers: cors });
    }

    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
      apiVersion: '2023-10-16',
    });
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const { room_id, success_url, cancel_url } = await req.json();

    // Fetch room
    const { data: room, error: roomErr } = await supabase
      .from('rooms')
      .select('title, price_cents, access_type')
      .eq('id', room_id)
      .single();

    if (roomErr || !room || room.access_type !== 'paid' || !room.price_cents) {
      return new Response(JSON.stringify({ error: 'Invalid room or not a paid room' }), {
        status: 400, headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    // Check if already paid
    const { data: existing } = await supabase
      .from('room_payments')
      .select('id')
      .eq('room_id', room_id)
      .eq('user_id', user.id)
      .eq('status', 'paid')
      .maybeSingle();
    if (existing) {
      return new Response(JSON.stringify({ already_paid: true }), {
        headers: { ...cors, 'Content-Type': 'application/json' },
      });
    }

    // Create Stripe Checkout session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: { name: `☕ Sukee Tea Chat: ${room.title}` },
          unit_amount: room.price_cents,
        },
        quantity: 1,
      }],
      mode: 'payment',
      success_url: `${success_url}&payment_success=1`,
      cancel_url,
      metadata: { room_id, user_id: user.id },
    });

    // Record pending payment
    await supabase.from('room_payments').insert({
      room_id,
      user_id: user.id,
      stripe_session_id: session.id,
      amount_cents: room.price_cents,
      status: 'pending',
    });

    return new Response(JSON.stringify({ url: session.url }), {
      headers: { ...cors, 'Content-Type': 'application/json' },
    });
  } catch (err) {
    console.error(err);
    return new Response(JSON.stringify({ error: (err as Error).message }), {
      status: 500, headers: { ...cors, 'Content-Type': 'application/json' },
    });
  }
});
