#!/usr/bin/env bash
# Deploy file(s) from site/ to the KIAS web server.

set -euo pipefail

DIR="$(dirname "$0")"
SITE="${DIR}/site"

usage() {
    cat <<'EOF'
Deploy file(s) from site/ to the KIAS web server.

Usage:
  ./deploy.sh YEAR             # deploys site/YEAR.html
  ./deploy.sh FILE [FILE ...]  # deploys named file(s) from site/
  ./deploy.sh -a | --all       # deploys every file in site/
  ./deploy.sh -h | --help      # show this help

Requires SSH key authentication (run once: ssh-copy-id root@astro.kias.re.kr).
EOF
}

case "${1-}" in
    -h|--help) usage; exit 0 ;;
    -a|--all)
        FILES=()
        for f in "$SITE"/*; do
            [[ -f "$f" ]] && FILES+=("$(basename "$f")")
        done
        set -- ${FILES[@]+"${FILES[@]}"}
        ;;
esac

HOST="astro.kias.re.kr"
USER="root"
REMOTE_DIR="/BACKUP3/www/html/KDES_seminar"
# SSH normally auto-tries keys with standard names like ~/.ssh/id_rsa or
# ~/.ssh/id_ed25519. This key has a custom filename, so we must tell scp
# which one to use with the -i flag below; otherwise it will fall back to
# asking for a password. The key file differs per host machine.
case "$(uname -s)" in
    Darwin) KEY="$HOME/.ssh/id_ed25519-remote-ssh-gate" ;;
    Linux)  KEY="$HOME/.ssh/id_ed25519-kias-astro" ;;
    *)      echo "error: unsupported OS $(uname -s)" >&2; exit 1 ;;
esac

if [[ $# -lt 1 ]]; then
    usage >&2
    exit 1
fi

for arg in "$@"; do
    if [[ "$arg" =~ ^[0-9]{4}$ ]]; then
        SRC="${SITE}/${arg}.html"
    else
        SRC="${SITE}/${arg}"
    fi
    if [[ ! -f "$SRC" ]]; then
        echo "error: $SRC not found" >&2
        exit 1
    fi
    BASENAME="$(basename "$SRC")"
    scp -i "$KEY" "$SRC" "$USER@$HOST:${REMOTE_DIR}/${BASENAME}"
    echo "Deployed $SRC -> $USER@$HOST:${REMOTE_DIR}/${BASENAME}"
done
