#!/usr/bin/env bash
# Deploy a year's HTML file to the KIAS web server.
# Usage: ./deploy.sh YEAR
# Requires SSH key authentication (run once: ssh-copy-id root@astro.kias.re.kr).

set -euo pipefail

HOST="astro.kias.re.kr"
USER="root"
# SSH normally auto-tries keys with standard names like ~/.ssh/id_rsa or
# ~/.ssh/id_ed25519. This key has a custom filename, so we must tell scp
# which one to use with the -i flag below; otherwise it will fall back to
# asking for a password.
KEY="$HOME/.ssh/id_ed25519-remote-ssh-gate"

if [[ $# -ne 1 ]]; then
    echo "usage: $0 YEAR" >&2
    exit 1
fi
YEAR="$1"
SRC="$(dirname "$0")/${YEAR}.html"
DEST="/BACKUP3/www/html/KDES_seminar/${YEAR}.html"

if [[ ! -f "$SRC" ]]; then
    echo "error: $SRC not found" >&2
    exit 1
fi

scp -i "$KEY" "$SRC" "$USER@$HOST:$DEST"
echo "Deployed $SRC -> $USER@$HOST:$DEST"
