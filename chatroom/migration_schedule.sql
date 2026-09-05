-- ============================================================
-- Tea Chat Room — Schedule & Duration Migration
-- Run in Supabase SQL Editor AFTER migration_access.sql
-- ============================================================

-- 1. Add scheduled_at and duration_mins to rooms
ALTER TABLE rooms
  ADD COLUMN IF NOT EXISTS scheduled_at  TIMESTAMPTZ DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS duration_mins INTEGER DEFAULT 15;

-- 2. Allow 'scheduled' as a room status
ALTER TABLE rooms DROP CONSTRAINT IF EXISTS rooms_status_check;
ALTER TABLE rooms ADD CONSTRAINT rooms_status_check
  CHECK (status IN ('open', 'active', 'closed', 'scheduled'));

-- Index for fast calendar queries
CREATE INDEX IF NOT EXISTS rooms_scheduled_at_idx ON rooms (scheduled_at)
  WHERE scheduled_at IS NOT NULL;
