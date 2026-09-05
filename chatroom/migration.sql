-- ============================================================
-- Tea Chat Room — Migration: add blog_id to rooms
-- Run in Supabase SQL Editor AFTER schema.sql
-- ============================================================

-- Links a chat room to a specific blog post by its slug ID
ALTER TABLE rooms ADD COLUMN IF NOT EXISTS blog_id TEXT DEFAULT NULL;

-- Index for fast lookup by blog post
CREATE INDEX IF NOT EXISTS rooms_blog_id_idx ON rooms (blog_id) WHERE blog_id IS NOT NULL;
