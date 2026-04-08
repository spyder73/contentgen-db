-- Migration 0005: media file data storage
-- Run this against the contentgen database on the VPS:
--
--   docker compose exec postgres psql -U <DB_USER> -d contentgen \
--     -f /scripts/migrate_0005.sql
--
-- Safe to re-run (uses IF NOT EXISTS / ON CONFLICT DO NOTHING).

BEGIN;

ALTER TABLE media_items
    ADD COLUMN IF NOT EXISTS file_data       BYTEA  NULL,
    ADD COLUMN IF NOT EXISTS file_mime_type  TEXT   NULL;

-- Advance alembic version so alembic upgrade head is a no-op
INSERT INTO alembic_version (version_num)
    VALUES ('0006')
    ON CONFLICT DO NOTHING;

COMMIT;
