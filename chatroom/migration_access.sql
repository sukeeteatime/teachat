-- ============================================================
-- Tea Chat Room — Access Control Migration
-- Run in Supabase SQL Editor AFTER schema.sql and migration.sql
-- ============================================================

-- 1. Add access control columns to rooms
ALTER TABLE rooms
  ADD COLUMN IF NOT EXISTS access_type TEXT DEFAULT 'open'
    CHECK (access_type IN ('open', 'paid', 'allowlist', 'invite_only')),
  ADD COLUMN IF NOT EXISTS price_cents INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS allowed_emails TEXT[] DEFAULT '{}';

-- 2. Invitations table (for invite_only rooms)
CREATE TABLE IF NOT EXISTS invitations (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id       UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  invited_email TEXT,
  token         TEXT UNIQUE NOT NULL DEFAULT encode(gen_random_bytes(24), 'base64url'),
  created_by    UUID NOT NULL REFERENCES auth.users(id),
  used_by       UUID REFERENCES auth.users(id),
  used_at       TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Room payments table (Stripe integration)
CREATE TABLE IF NOT EXISTS room_payments (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id                  UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  user_id                  UUID NOT NULL REFERENCES auth.users(id),
  stripe_session_id        TEXT UNIQUE,
  stripe_payment_intent_id TEXT,
  amount_cents             INTEGER NOT NULL,
  status                   TEXT DEFAULT 'pending'
    CHECK (status IN ('pending', 'paid', 'failed', 'refunded')),
  created_at               TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Enable RLS on new tables
ALTER TABLE invitations  ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_payments ENABLE ROW LEVEL SECURITY;

-- Invitations: host full control; anyone can read (for token lookup); anyone can claim unclaimed token
CREATE POLICY "Host manages own invitations" ON invitations
  FOR ALL USING (created_by = auth.uid());

CREATE POLICY "Anyone can read invite tokens" ON invitations
  FOR SELECT USING (true);

CREATE POLICY "Claim unclaimed invite" ON invitations
  FOR UPDATE USING (used_by IS NULL)
  WITH CHECK (used_by = auth.uid());

-- Payments: user sees/creates their own rows; service role (webhook) updates via SUPABASE_SERVICE_ROLE_KEY
CREATE POLICY "User sees own payments" ON room_payments
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "User creates pending payment" ON room_payments
  FOR INSERT WITH CHECK (user_id = auth.uid() AND status = 'pending');

-- 5. Replace room_members INSERT policy to enforce access types
DROP POLICY IF EXISTS "Members can join open or active rooms" ON room_members;

CREATE POLICY "Members can join with access check" ON room_members
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM rooms r
      WHERE r.id = room_id
        AND r.status IN ('open', 'active')
        AND (
          -- Open: anyone
          r.access_type = 'open'
          -- Host always allowed in their own room
          OR r.created_by = auth.uid()
          -- Paid: confirmed payment required
          OR (r.access_type = 'paid'
              AND EXISTS (
                SELECT 1 FROM room_payments p
                WHERE p.room_id = r.id
                  AND p.user_id = auth.uid()
                  AND p.status = 'paid'))
          -- Allowlist: user email must be in the list
          OR (r.access_type = 'allowlist'
              AND (auth.jwt() ->> 'email') = ANY(r.allowed_emails))
          -- Invite only: must have a claimed invite
          OR (r.access_type = 'invite_only'
              AND EXISTS (
                SELECT 1 FROM invitations i
                WHERE i.room_id = r.id
                  AND i.used_by = auth.uid()))
        )
    )
  );

-- 6. Add new tables to realtime
ALTER PUBLICATION supabase_realtime ADD TABLE invitations;
ALTER PUBLICATION supabase_realtime ADD TABLE room_payments;
