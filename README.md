# contentgen-db

PostgreSQL persistence layer for the contentgen stack.
Runs on a separate VPS; the `contentgen-store-service` connects to it over the network.

## Quick start (VPS)

```bash
git clone <this-repo> contentgen-db
cd contentgen-db
bash scripts/setup.sh   # installs Docker, creates .env, starts Postgres
```

Schema is applied automatically on first start via `init/01_schema.sql`.

## Connect the app server

Pick **one** of the options below, then set these in your app server's `.env`:

```
DB_HOST=<vps-ip-or-hostname>
DB_USER=contentgen
DB_PASS=<password from .env on VPS>
```

### Option A — Firewall + direct TCP (simplest)

1. On the VPS, open port 5432 for your app server's IP only:
   ```bash
   ufw allow from <APP_SERVER_IP> to any port 5432
   ```
2. In `docker-compose.yml`, change the port binding to:
   ```yaml
   ports:
     - "0.0.0.0:5432:5432"
   ```
3. `make down && make up`

### Option B — SSH tunnel (no firewall changes needed)

On the app server, open a persistent tunnel:
```bash
ssh -N -L 5432:127.0.0.1:5432 user@<VPS_IP> &
```
Then use `DB_HOST=127.0.0.1` in the app server's `.env`.

For a persistent tunnel use `autossh` or a systemd unit.

### Option C — Tailscale (recommended for multi-machine setups)

Install Tailscale on both machines. Use the VPS Tailscale IP as `DB_HOST`.
No firewall rules needed; traffic is encrypted by default.

## Useful commands

```bash
make up       # start Postgres
make down     # stop
make logs     # follow logs
make shell    # psql shell
make backup   # dump to backups/
```

## Schema changes

Future migrations live in `contentgen-store-service/alembic/versions/`.
After pulling new migrations on the store service, run:

```bash
docker compose run --rm store alembic upgrade head
```
