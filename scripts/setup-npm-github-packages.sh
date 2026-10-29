#!/usr/bin/env bash
# Add GitHub Packages registry for @raullazaro (does not replace full ~/.npmrc).
# Prefer dotbot-linked `npmrc` in this repo for security defaults.

set -u

log()  { printf '[npm] %s\n' "$*"; }
warn() { printf '[npm] WARNING: %s\n' "$*" >&2; }

NPMRC="$HOME/.npmrc"
MARKER="@raullazaro:registry="

if [ ! -f "$NPMRC" ]; then
  warn "~/.npmrc missing — run ./install in dotfiles first (links npmrc)"
  exit 1
fi

if grep -q "$MARKER" "$NPMRC" 2>/dev/null; then
  log "GitHub Packages registry already in $NPMRC"
  exit 0
fi

cat >> "$NPMRC" <<'EOF'

# GitHub Packages — @raullazaro scope (setup-npm-github-packages.sh)
@raullazaro:registry=https://npm.pkg.github.com
# For publishing: npm config set //npm.pkg.github.com/:_authToken YOUR_TOKEN
EOF

log "appended GitHub Packages lines to $NPMRC"
