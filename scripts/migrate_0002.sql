-- Migration 0002: series, characters, episodes, voice_snippets
-- Run this against the contentgen database on the VPS:
--
--   psql -U <DB_USER> -d contentgen -f scripts/migrate_0002.sql
--
-- Or from inside the postgres container:
--
--   docker compose exec postgres psql -U <DB_USER> -d contentgen \
--     -c "$(cat scripts/migrate_0002.sql)"
--
-- Safe to re-run (uses IF NOT EXISTS / ON CONFLICT DO NOTHING).

BEGIN;

CREATE TABLE IF NOT EXISTS series (
    id          UUID PRIMARY KEY,
    name        TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    concept     TEXT NOT NULL DEFAULT '',
    metadata    JSONB NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS characters (
    id                       UUID PRIMARY KEY,
    series_id                UUID NOT NULL REFERENCES series(id) ON DELETE CASCADE,
    name                     TEXT NOT NULL,
    description              TEXT NOT NULL DEFAULT '',
    voice                    TEXT NOT NULL DEFAULT '',
    reference_image_media_id UUID REFERENCES media_items(id) ON DELETE SET NULL,
    metadata                 JSONB NOT NULL DEFAULT '{}',
    created_at               TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at               TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_characters_series_id ON characters(series_id);

CREATE TABLE IF NOT EXISTS episodes (
    id                   UUID PRIMARY KEY,
    series_id            UUID NOT NULL REFERENCES series(id) ON DELETE CASCADE,
    episode_number       INTEGER NOT NULL DEFAULT 0,
    title                TEXT NOT NULL DEFAULT '',
    synopsis             TEXT NOT NULL DEFAULT '',
    prev_episode_summary TEXT NOT NULL DEFAULT '',
    metadata             JSONB NOT NULL DEFAULT '{}',
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_episodes_series_id ON episodes(series_id);

CREATE TABLE IF NOT EXISTS voice_snippets (
    id           UUID PRIMARY KEY,
    character_id UUID NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    file_url     TEXT NOT NULL DEFAULT '',
    duration     FLOAT NOT NULL DEFAULT 0.0,
    metadata     JSONB NOT NULL DEFAULT '{}',
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_voice_snippets_character_id ON voice_snippets(character_id);

-- Advance alembic version so alembic upgrade head is a no-op
INSERT INTO alembic_version (version_num)
    VALUES ('0002')
    ON CONFLICT DO NOTHING;

COMMIT;
