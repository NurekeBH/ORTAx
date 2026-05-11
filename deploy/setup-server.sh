#!/usr/bin/env bash
# Бір реттік server bootstrap скрипті
# Ubuntu 22.04 LTS / VPS 2 CPU / 2 GB RAM
#
# Қолдану: root болып немесе sudo арқылы орындау:
#   curl -fsSL https://your-domain.kz/setup-server.sh | sudo bash
# немесе локалды файлдан:
#   sudo bash setup-server.sh

set -euo pipefail

APP_USER="ortax"
APP_DIR="/opt/ortax"
NODE_MAJOR=20
PG_VERSION=16
PG_DB="ortax"
PG_USER="ortax"
PG_PASSWORD="$(openssl rand -hex 16)"

echo "▶ ORTAx backend server bootstrap"
echo "  App user: $APP_USER"
echo "  App dir:  $APP_DIR"
echo "  Postgres: $PG_DB / $PG_USER"
echo

# 1. System update
apt-get update
apt-get upgrade -y
apt-get install -y curl ca-certificates gnupg lsb-release ufw build-essential git unzip

# 2. Node.js 20.x via NodeSource
if ! command -v node >/dev/null 2>&1 || [[ "$(node -v | cut -d. -f1 | tr -d v)" -lt "$NODE_MAJOR" ]]; then
  echo "▶ Installing Node.js ${NODE_MAJOR}.x"
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash -
  apt-get install -y nodejs
fi
node -v
npm -v

# 3. PostgreSQL
if ! command -v psql >/dev/null 2>&1; then
  echo "▶ Installing PostgreSQL ${PG_VERSION}"
  install -d /usr/share/postgresql-common/pgdg
  curl -fsSL "https://www.postgresql.org/media/keys/ACCC4CF8.asc" -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc
  echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list
  apt-get update
  apt-get install -y "postgresql-${PG_VERSION}" "postgresql-client-${PG_VERSION}"
  systemctl enable --now postgresql
fi

# 4. nginx + certbot
apt-get install -y nginx certbot python3-certbot-nginx

# 5. UFW (firewall) — SSH + HTTP + HTTPS
ufw allow OpenSSH || true
ufw allow 'Nginx Full' || true
ufw --force enable
ufw status

# 6. App user
if ! id "$APP_USER" >/dev/null 2>&1; then
  echo "▶ Creating user $APP_USER"
  useradd --create-home --shell /bin/bash "$APP_USER"
fi

# 7. App directory
mkdir -p "$APP_DIR"
chown -R "$APP_USER:$APP_USER" "$APP_DIR"

# 8. PostgreSQL DB + user
echo "▶ Creating PG database '$PG_DB' and user '$PG_USER'"
sudo -u postgres psql <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$PG_USER') THEN
    CREATE ROLE $PG_USER LOGIN PASSWORD '$PG_PASSWORD';
  END IF;
END
\$\$;
SELECT 'CREATE DATABASE $PG_DB OWNER $PG_USER' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$PG_DB')\gexec
GRANT ALL PRIVILEGES ON DATABASE $PG_DB TO $PG_USER;
SQL

# 9. Save credentials to a file accessible only by root
mkdir -p /root/ortax
cat > /root/ortax/db-credentials.env <<EOF
# Generated $(date)
DB_HOST=127.0.0.1
DB_PORT=5432
DB_USER=$PG_USER
DB_PASSWORD=$PG_PASSWORD
DB_NAME=$PG_DB
EOF
chmod 600 /root/ortax/db-credentials.env

echo
echo "✅ Server bootstrap complete."
echo
echo "PG password generated and saved to /root/ortax/db-credentials.env"
echo "Use it when filling /opt/ortax/backend/.env"
echo
echo "Next steps:"
echo "  1. As root: copy your repo into $APP_DIR (git clone)"
echo "     chown -R $APP_USER:$APP_USER $APP_DIR"
echo "  2. As $APP_USER: cd $APP_DIR/backend && npm ci && npm run build"
echo "  3. Create /opt/ortax/backend/.env using .env.production.example as a template"
echo "  4. Install systemd unit: cp deploy/ortax-backend.service /etc/systemd/system/"
echo "     systemctl daemon-reload && systemctl enable --now ortax-backend"
echo "  5. Configure nginx + certbot (see deploy/README.md)"
