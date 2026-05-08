#!/usr/bin/env bash
# Deploy file(s) to the KIAS web server.
# Usage:
#   ./deploy.sh YEAR             # deploys YEAR.html
#   ./deploy.sh FILE [FILE ...]  # deploys arbitrary file(s) from this dir
# Requires SSH key authentication (run once: ssh-copy-id root@astro.kias.re.kr).

set -euo pipefail

HOST="astro.kias.re.kr"
USER="root"
REMOTE_DIR="/BACKUP3/www/html/KDES_seminar"
# SSH normally auto-tries keys with standard names like ~/.ssh/id_rsa or
# ~/.ssh/id_ed25519. This key has a custom filename, so we must tell scp
# which one to use with the -i flag below; otherwise it will fall back to
# asking for a password.
KEY="$HOME/.ssh/id_ed25519-remote-ssh-gate"

if [[ $# -lt 1 ]]; then
    echo "usage: $0 YEAR | FILE [FILE ...]" >&2
    exit 1
fi

DIR="$(dirname "$0")"

for arg in "$@"; do
    if [[ "$arg" =~ ^[0-9]{4}$ ]]; then
        SRC="${DIR}/${arg}.html"
    else
        SRC="${DIR}/${arg}"
    fi
    if [[ ! -f "$SRC" ]]; then
        echo "error: $SRC not found" >&2
        exit 1
    fi
    BASENAME="$(basename "$SRC")"
    scp -i "$KEY" "$SRC" "$USER@$HOST:${REMOTE_DIR}/${BASENAME}"
    echo "Deployed $SRC -> $USER@$HOST:${REMOTE_DIR}/${BASENAME}"
done
