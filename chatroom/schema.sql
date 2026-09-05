-- ============================================================
-- Tea Chat Room — Supabase Schema
-- Paste into Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- Profiles (one row per auth user)
CREATE TABLE IF NOT EXISTS profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name  TEXT NOT NULL DEFAULT 'Guest',
  avatar_color  TEXT NOT NULL DEFAULT '#8B7355',
  bio           TEXT NOT NULL DEFAULT '',
  is_admin      BOOLEAN NOT NULL DEFAULT FALSE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-create profile when a user signs up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data ->> 'display_name', split_part(NEW.email, '@', 1))
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Chat rooms
CREATE TABLE IF NOT EXISTS rooms (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           TEXT NOT NULL,
  topic           TEXT NOT NULL DEFAULT '',
  created_by      UUID REFERENCES profiles(id) ON DELETE SET NULL,
  capacity        INT NOT NULL DEFAULT 6 CHECK (capacity BETWEEN 1 AND 50),
  status          TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open','active','closed')),
  started_at      TIMESTAMPTZ,
  expires_at      TIMESTAMPTZ,
  delete_on_close BOOLEAN NOT NULL DEFAULT FALSE,
  admin_summary   TEXT NOT NULL DEFAULT '',
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Who is currently in a room
CREATE TABLE IF NOT EXISTS room_members (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id      UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  user_id      UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
  joined_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(room_id, user_id)
);

-- Waiting list
CREATE TABLE IF NOT EXISTS waitlist (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id   UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(room_id, user_id)
);

-- Chat messages
CREATE TABLE IF NOT EXISTS messages (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id      UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  user_id      UUID REFERENCES profiles(id) ON DELETE SET NULL,
  content      TEXT NOT NULL CHECK (char_length(content) BETWEEN 1 AND 1000),
  is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Room followers
CREATE TABLE IF NOT EXISTS followers (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id   UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  user_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(room_id, user_id)
);

-- ============================================================
-- Row Level Security
-- ============================================================

ALTER TABLE profiles    ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms       ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE waitlist    ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages    ENABLE ROW LEVEL SECURITY;
ALTER TABLE followers   ENABLE ROW LEVEL SECURITY;

-- Profiles
CREATE POLICY "profiles_select" ON profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Rooms
CREATE POLICY "rooms_select" ON rooms FOR SELECT USING (true);
CREATE POLICY "rooms_insert" ON rooms FOR INSERT WITH CHECK (auth.uid() IS NOT NULL AND auth.uid() = created_by);
CREATE POLICY "rooms_update" ON rooms FOR UPDATE USING (
  auth.uid() = created_by
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin)
);

-- Room members
CREATE POLICY "members_select" ON room_members FOR SELECT USING (true);
CREATE POLICY "members_insert" ON room_members FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "members_delete" ON room_members FOR DELETE USING (auth.uid() = user_id);

-- Waitlist
CREATE POLICY "waitlist_select" ON waitlist FOR SELECT USING (true);
CREATE POLICY "waitlist_insert" ON waitlist FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "waitlist_delete" ON waitlist FOR DELETE USING (auth.uid() = user_id);

-- Messages: members see active-room messages; everyone sees closed-room messages
CREATE POLICY "messages_select" ON messages FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM rooms r WHERE r.id = messages.room_id AND (
      r.status = 'closed'
      OR (r.status = 'active' AND EXISTS (
        SELECT 1 FROM room_members m WHERE m.room_id = r.id AND m.user_id = auth.uid()
      ))
    )
  )
);
CREATE POLICY "messages_insert" ON messages FOR INSERT WITH CHECK (
  auth.uid() = user_id
  AND EXISTS (SELECT 1 FROM rooms WHERE id = room_id AND status = 'active')
  AND EXISTS (SELECT 1 FROM room_members WHERE room_id = room_id AND user_id = auth.uid())
);
CREATE POLICY "messages_delete" ON messages FOR DELETE USING (
  auth.uid() = user_id
  OR EXISTS (SELECT 1 FROM rooms WHERE id = messages.room_id AND created_by = auth.uid())
  OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND is_admin)
);

-- Followers (own rows only)
CREATE POLICY "followers_select" ON followers FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "followers_insert" ON followers FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "followers_delete" ON followers FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- Enable Realtime
-- ============================================================
ALTER PUBLICATION supabase_realtime ADD TABLE rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE room_members;
ALTER PUBLICATION supabase_realtime ADD TABLE waitlist;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
