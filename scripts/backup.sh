#!/usr/bin/env bash
# Dump the contentgen database to a timestamped .sql.gz file.
set -euo pipefail

source .env

OUTDIR="${BACKUP_DIR:-./backups}"
mkdir -p "$OUTDIR"
FILENAME="${OUTDIR}/contentgen_$(date +%Y%m%d_%H%M%S).sql.gz"

docker compose exec -T postgres \
  pg_dump -U "$DB_USER" contentgen \
  | gzip > "$FILENAME"

echo "Backup written to $FILENAME"
