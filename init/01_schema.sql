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
    id          UUID PRIMARY KEY,
    name        TEXT NOT NULL DEFAULT '',
    metadata    JSONB NOT NULL DEFAULT '{}',
    style       JSONB NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS media_items (
    id          UUID PRIMARY KEY,
    clip_id     UUID REFERENCES clip_prompts(id) ON DELETE SET NULL,
    type        TEXT NOT NULL,
    prompt      TEXT NOT NULL DEFAULT '',
    file_url    TEXT NOT NULL DEFAULT '',
    metadata    JSONB NOT NULL DEFAULT '{}',
    output_spec JSONB,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_media_items_clip_id    ON media_items(clip_id);
CREATE INDEX IF NOT EXISTS ix_media_items_type       ON media_items(type);
CREATE INDEX IF NOT EXISTS ix_media_items_created_at ON media_items(created_at DESC);

-- alembic_version stub so alembic treats the DB as already at revision 0001
-- (prevents double-applying the initial migration if you run alembic later)
CREATE TABLE IF NOT EXISTS alembic_version (
    version_num TEXT NOT NULL,
    CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)
);
INSERT INTO alembic_version (version_num)
    VALUES ('0001')
    ON CONFLICT DO NOTHING;
