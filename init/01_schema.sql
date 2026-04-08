-- contentgen schema
-- This file runs automatically on first container start (empty volume).
-- For subsequent schema changes, run migrations via alembic in the store service.

CREATE TABLE IF NOT EXISTS pipeline_templates (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    data        JSONB NOT NULL,
    version     INTEGER NOT NULL DEFAULT 1,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS prompt_templates (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    content     TEXT NOT NULL,
    metadata    JSONB NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS clip_prompts (
    id                  UUID PRIMARY KEY,
    name                TEXT NOT NULL DEFAULT '',
    metadata            JSONB NOT NULL DEFAULT '{}',
    style               JSONB NOT NULL DEFAULT '{}',
    media_refs          JSONB NOT NULL DEFAULT '{"images":[],"ai_videos":[],"audios":[]}',
    render_output_urls  JSONB NOT NULL DEFAULT '[]',
    is_dirty            BOOLEAN NOT NULL DEFAULT FALSE,
    finished_at         TIMESTAMPTZ NULL,
    thumbnail_url       TEXT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS media_items (
    id               UUID PRIMARY KEY,
    clip_id          UUID REFERENCES clip_prompts(id) ON DELETE SET NULL,
    type             TEXT NOT NULL,
    prompt           TEXT NOT NULL DEFAULT '',
    file_url         TEXT NOT NULL DEFAULT '',
    metadata         JSONB NOT NULL DEFAULT '{}',
    output_spec      JSONB,
    is_favourite     BOOLEAN NOT NULL DEFAULT FALSE,
    name             TEXT NOT NULL DEFAULT '',
    pipeline_run_id  UUID NULL,
    scene_id         TEXT NULL,
    parent_media_id  UUID NULL REFERENCES media_items(id) ON DELETE SET NULL,
    role             TEXT NULL,
    file_data        BYTEA  NULL,
    file_mime_type   TEXT   NULL,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_media_items_clip_id            ON media_items(clip_id);
CREATE INDEX IF NOT EXISTS ix_media_items_type               ON media_items(type);
CREATE INDEX IF NOT EXISTS ix_media_items_created_at         ON media_items(created_at DESC);
CREATE INDEX IF NOT EXISTS ix_media_items_pipeline_run_id    ON media_items(pipeline_run_id);
CREATE INDEX IF NOT EXISTS ix_media_items_scene_id           ON media_items(scene_id);
CREATE INDEX IF NOT EXISTS ix_media_items_name               ON media_items(name);
CREATE INDEX IF NOT EXISTS ix_media_items_pipeline_scene_type ON media_items(pipeline_run_id, scene_id, type);

-- System prompts (migration 0004)

CREATE TABLE IF NOT EXISTS system_prompts (
    id          TEXT PRIMARY KEY,
    content     TEXT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Series / Characters / Episodes / VoiceSnippets (migration 0002)

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

-- alembic_version stub so alembic treats the DB as already at revision 0002
-- (prevents double-applying migrations if you run alembic later)
CREATE TABLE IF NOT EXISTS alembic_version (
    version_num TEXT NOT NULL,
    CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);
INSERT INTO alembic_version (version_num)
    VALUES ('0001')
    ON CONFLICT DO NOTHING;
INSERT INTO alembic_version (version_num)
    VALUES ('0002')
    ON CONFLICT DO NOTHING;
INSERT INTO alembic_version (version_num)
    VALUES ('0003')
    ON CONFLICT DO NOTHING;
INSERT INTO alembic_version (version_num)
    VALUES ('0004')
    ON CONFLICT DO NOTHING;
INSERT INTO alembic_version (version_num)
    VALUES ('0005')
    ON CONFLICT DO NOTHING;
INSERT INTO alembic_version (version_num)
    VALUES ('0006')
    ON CONFLICT DO NOTHING;
