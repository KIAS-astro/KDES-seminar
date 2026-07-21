#!/bin/sh
# Deploy file(s) from site/ to the KIAS web server.
# POSIX shell: runs the same under sh, bash (incl. macOS 3.2), and zsh.

set -eu

DIR="$(dirname "$0")"
SITE="${DIR}/site"

HOST="astro.kias.re.kr"
REMOTE_USER="root"
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

usage() {
    cat <<EOF
Deploy file(s) from site/ to the KIAS web server.

Usage:
  ./deploy.sh YEAR             # deploys site/YEAR.html
  ./deploy.sh FILE [FILE ...]  # deploys named file(s) from site/
  ./deploy.sh -a | --all       # deploys every file in site/
  ./deploy.sh -h | --help      # show this help

Requires SSH key authentication (run once: ssh-copy-id $REMOTE_USER@$HOST).
EOF
}

deploy_one() {
    # $1 is a YEAR (4 digits) or a filename under site/
    case "$1" in
        [0-9][0-9][0-9][0-9]) src="${SITE}/$1.html" ;;
        *)                    src="${SITE}/$1" ;;
    esac
    if [ ! -f "$src" ]; then
        echo "error: $src not found" >&2
        exit 1
    fi
    base="$(basename "$src")"
    scp -i "$KEY" "$src" "$REMOTE_USER@$HOST:${REMOTE_DIR}/${base}"
    echo "Deployed $src -> $REMOTE_USER@$HOST:${REMOTE_DIR}/${base}"
}

case "${1-}" in
    -h|--help) usage; exit 0 ;;
    -a|--all)
        for f in "$SITE"/*; do
            [ -f "$f" ] && deploy_one "$(basename "$f")"
        done
        exit 0 ;;
esac

if [ $# -lt 1 ]; then
    usage >&2
    exit 1
fi

for arg in "$@"; do
    deploy_one "$arg"
done
