#!/usr/bin/env bash
# Жаңартудан кейінгі деплой:
#   ssh root@vps "cd /opt/ortax && sudo -u ortax bash deploy/deploy.sh"
# Немесе ortax user-мен:
#   ssh ortax@vps "cd /opt/ortax && bash deploy/deploy.sh && sudo systemctl restart ortax-backend"

set -euo pipefail

APP_DIR="${APP_DIR:-/opt/ortax}"
BACKEND_DIR="$APP_DIR/backend"

cd "$APP_DIR"

echo "▶ git pull"
git pull --ff-only

echo "▶ npm ci"
cd "$BACKEND_DIR"
npm ci --omit=optional

echo "▶ npm run build"
npm run build

echo "✅ Code updated. Now run (as root):"
echo "   systemctl restart ortax-backend"
echo "   systemctl status ortax-backend --no-pager"
