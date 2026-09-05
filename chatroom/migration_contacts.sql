-- ============================================================
-- Tea Chat Room — Contacts & Guest Join Migration
-- Run in Supabase SQL Editor AFTER migration_schedule.sql
-- ============================================================

-- 1. Add email to profiles so contacts can detect system membership
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;

-- Backfill existing rows from auth.users
UPDATE profiles p
SET email = u.email
FROM auth.users u
WHERE u.id = p.id AND p.email IS NULL;

-- Keep email in sync when new users sign up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'display_name', split_part(NEW.email, '@', 1)),
    NEW.email
  )
  ON CONFLICT (id) DO UPDATE SET email = EXCLUDED.email;
  RETURN NEW;
END;
$$;

-- 2. user_contacts — each user's saved contacts by email
CREATE TABLE IF NOT EXISTS user_contacts (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  email      TEXT        NOT NULL,
  nickname   TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, email)
);

ALTER TABLE user_contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own contacts" ON user_contacts
  FOR ALL USING (auth.uid() = user_id);

-- 3. guest_name on room_members and messages (for anonymous join via invite)
ALTER TABLE room_members ADD COLUMN IF NOT EXISTS guest_name TEXT;
ALTER TABLE messages     ADD COLUMN IF NOT EXISTS guest_name TEXT;

-- 4. RPC: resolve a list of emails → system membership + display info
--    Called client-side to label contacts as "in system" or "email only"
CREATE OR REPLACE FUNCTION resolve_contact_emails(emails TEXT[])
RETURNS TABLE(
  email        TEXT,
  in_system    BOOLEAN,
  display_name TEXT,
  avatar_color TEXT
)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  RETURN QUERY
  SELECT
    e.email,
    EXISTS (SELECT 1 FROM profiles p WHERE lower(p.email) = lower(e.email)) AS in_system,
    (SELECT p.display_name FROM profiles p WHERE lower(p.email) = lower(e.email) LIMIT 1),
    (SELECT p.avatar_color FROM profiles p WHERE lower(p.email) = lower(e.email) LIMIT 1)
  FROM unnest(emails) AS e(email);
END;
$$;
