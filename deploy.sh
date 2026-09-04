#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# mehrdad.ir — cPanel deploy (runs on the HOST, invoked by .cpanel.yml hook
# or manually — no SSH needed).
#
# v2 (2026-09-04): artifact mehrdad-deploy-20260904-183256.tar.gz ships BOTH
# Prisma engines (host runtime resolved to debian-openssl-1.0.x — see diag).
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
else
  mkdir -p "$APP/data"
  cp custom.db "$APP/data/production.db"
  echo "    seeded data/production.db ✓"
fi

echo "==> [4/4] passenger restart hint + cleanup"
mkdir -p "$APP/tmp" && touch "$APP/tmp/restart.txt"
rm -f "$TARBALL"
du -sh "$APP"
echo ""
echo "DONE. Remaining steps are cPanel UI only — see README.md in this repo."
echo "  DATABASE_URL=file:$APP/data/production.db"
