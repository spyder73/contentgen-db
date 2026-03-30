-- Migration 0003: add is_favourite to media_items
-- Run this against the contentgen database on the VPS:
--
--   psql -U <DB_USER> -d contentgen -f scripts/migrate_0003.sql
--
-- Or from inside the postgres container:
--
--   docker compose exec postgres psql -U <DB_USER> -d contentgen \
--     -f /scripts/migrate_0003.sql
--
-- Safe to re-run (uses IF NOT EXISTS column add).

BEGIN;

ALTER TABLE media_items
    ADD COLUMN IF NOT EXISTS is_favourite BOOLEAN NOT NULL DEFAULT FALSE;

-- Advance alembic version so alembic upgrade head is a no-op
INSERT INTO alembic_version (version_num)
    VALUES ('0003')
    ON CONFLICT DO NOTHING;

COMMIT;
