#!/usr/bin/env bash
# First-time setup on a fresh VPS.
# Run as root or a user with sudo access.
set -euo pipefail

# ── 1. Install Docker if not present ────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  echo "Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  systemctl enable --now docker
fi

# ── 2. Create .env if missing ────────────────────────────────────────────────
if [ ! -f .env ]; then
  cp .env.example .env
  # Generate a random 32-char password
  PASS=$(tr -dc 'A-Za-z0-9!@#$%^&*' </dev/urandom | head -c 32 || true)
  sed -i "s/change-me-to-something-strong/${PASS}/" .env
  echo ""
  echo "✅ Generated .env with a random DB password."
  echo "   Record it now — it won't be shown again:"
  grep DB_PASS .env
  echo ""
fi

# ── 3. Open firewall for app server ─────────────────────────────────────────
echo ""
echo "📋 Firewall: allow your app-server IP to reach port 5432."
echo "   Example (ufw):  ufw allow from <APP_SERVER_IP> to any port 5432"
echo "   Then update docker-compose.yml port binding to 0.0.0.0:5432:5432"
echo "   OR keep 127.0.0.1 and use an SSH tunnel / Tailscale instead."
echo ""

# ── 4. Start PostgreSQL ──────────────────────────────────────────────────────
docker compose up -d

echo ""
echo "✅ PostgreSQL is running. Test with:"
echo "   docker compose exec postgres psql -U \$(grep DB_USER .env | cut -d= -f2) -d contentgen -c '\\dt'"
