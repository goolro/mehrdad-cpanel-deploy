#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# mehrdad.ir — cPanel deploy (runs on the HOST, invoked by .cpanel.yml hook
# or manually — no SSH needed).
#
# v3 (2026-09-05): artifact mehrdad-deploy-20260905-222550.tar.gz (main@bd947c7) ships BOTH
# Prisma engines (host runtime resolved to debian-openssl-1.0.x — see diag).
# v3.2 (2026-09-06): DB step is fresh-host tolerant — public repo ships NO custom.db
# (removed for privacy), so a first deploy on an empty host prints a NOTE instead of
# failing; Turso cloud DB (TURSO_* env) needs no file at all.
#
# Reassembles the artifact from git chunks, verifies SHA256, extracts into
# ~/mehrdad-app and seeds data/production.db ONCE (never overwrites prod data).
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
APP="$HOME/mehrdad-app"
TARBALL="mehrdad-deploy.tar.gz"

cd "$DIR"
echo "==> [1/4] reassemble artifact from git chunks"
cat artifact.part.* > "$TARBALL"
sha256sum -c SHA256SUMS.repo

echo "==> [2/4] extract into $APP"
mkdir -p "$APP"
tar -xzf "$TARBALL" -C "$APP"
test -f "$APP/server.js" || { echo "FATAL: server.js missing"; exit 1; }
echo "    server.js OK · Prisma engines: $(ls "$APP"/node_modules/.prisma/client/libquery_engine-*.so.node 2>/dev/null | wc -l)"

echo "==> [3/4] production DB (create-once policy)"
if [ -f "$APP/data/production.db" ]; then
  echo "    data/production.db exists — LEFT UNTOUCHED ✓"
elif [ -f custom.db ]; then
  mkdir -p "$APP/data"
  cp custom.db "$APP/data/production.db"
  echo "    seeded data/production.db ✓"
else
  mkdir -p "$APP/data"
  echo "    NOTE: no data/production.db on host and no custom.db in this public repo"
  echo "    (removed from the repo for privacy). This is FINE when the app uses"
  echo "    TURSO_DATABASE_URL + TURSO_AUTH_TOKEN (DB lives in Turso cloud)."
  echo "    Otherwise upload a DB file to $APP/data/production.db via File Manager"
  echo "    before Restart."
fi

echo "==> [4/4] passenger restart hint + cleanup"
mkdir -p "$APP/tmp" && touch "$APP/tmp/restart.txt"
rm -f "$TARBALL"
du -sh "$APP"
echo ""
echo "DONE. Remaining steps are cPanel UI only — see README.md in this repo."
echo "  DB mode A (primary): set TURSO_DATABASE_URL + TURSO_AUTH_TOKEN env vars"
echo "  DB mode B (fallback): DATABASE_URL=file:$APP/data/production.db (needs the file)"
