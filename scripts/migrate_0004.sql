-- Migration 0004: add system_prompts table
-- Run this against the contentgen database on the VPS:
--
--   psql -U <DB_USER> -d contentgen -f scripts/migrate_0004.sql
--
-- Or from inside the postgres container:
--
--   docker compose exec postgres psql -U <DB_USER> -d contentgen \
--     -f /scripts/migrate_0004.sql
--
-- Safe to re-run (uses CREATE TABLE IF NOT EXISTS).

BEGIN;

CREATE TABLE IF NOT EXISTS system_prompts (
    id         TEXT PRIMARY KEY,
    content    TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Advance alembic version so alembic upgrade head is a no-op
INSERT INTO alembic_version (version_num)
    VALUES ('0004')
    ON CONFLICT DO NOTHING;

COMMIT;
