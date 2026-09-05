-- ============================================================
-- Tea Chat Room — Recap Fields Migration
-- Run in Supabase SQL Editor AFTER migration_schedule.sql
-- ============================================================

-- Add structured recap fields alongside the existing admin_summary (full content)
ALTER TABLE rooms
  ADD COLUMN IF NOT EXISTS recap_title   TEXT NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS recap_excerpt TEXT NOT NULL DEFAULT '';
