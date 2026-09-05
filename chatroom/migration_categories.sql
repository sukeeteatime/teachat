-- ============================================================
-- Tea Chat Room — Categories & Tags Migration
-- Run in Supabase SQL Editor AFTER migration_contacts.sql
-- ============================================================

-- 1. Add category + tags to rooms
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS category TEXT    DEFAULT 'Open Chat';
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS tags     TEXT[]  DEFAULT '{}';

-- 2. Central tag registry — tracks all tags used so the UI can suggest them
CREATE TABLE IF NOT EXISTS room_tags (
  tag         TEXT    PRIMARY KEY,
  usage_count INTEGER NOT NULL DEFAULT 1,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE room_tags ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone reads tags"    ON room_tags FOR SELECT USING (true);
CREATE POLICY "Auth users add tags"  ON room_tags FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);
CREATE POLICY "Auth users increment" ON room_tags FOR UPDATE USING (auth.uid() IS NOT NULL);

-- 3. RPC: upsert a list of tags and return the full tag list for suggestions
CREATE OR REPLACE FUNCTION upsert_room_tags(new_tags TEXT[])
RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO room_tags (tag)
    SELECT unnest(new_tags)
  ON CONFLICT (tag) DO UPDATE SET usage_count = room_tags.usage_count + 1;
END;
$$;
