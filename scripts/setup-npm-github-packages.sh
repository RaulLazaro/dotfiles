#!/usr/bin/env bash
# Set up npm for GitHub Packages (@raullazaro scope).
# Reads the token from `gh auth token` — no secrets in dotfiles.
#
# Token needs scopes: read:packages, write:packages
# Create at: https://github.com/settings/tokens?type=beta

set -u

log()  { printf '[npm] %s\n' "$*"; }
warn() { printf '[npm] WARNING: %s\n' "$*" >&2; }

NPMRC="$HOME/.npmrc"

# Ensure gh is available
if ! command -v gh >/dev/null 2>&1; then
  warn "gh not found — skipping npm GitHub Packages setup"
  exit 0
fi

# Get token from gh auth
TOKEN="$(gh auth token 2>/dev/null)"
if [ -z "$TOKEN" ]; then
  warn "gh not authenticated — run 'gh auth login' first"
  exit 0
fi

# Write ~/.npmrc
cat > "$NPMRC" <<EOF
# GitHub Packages — @raullazaro scope
# Token needs: read:packages, write:packages
@raullazaro:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${TOKEN}
EOF

log "wrote $NPMRC with GitHub Packages registry"
log "token scopes: run 'curl -sI -H \"Authorization: token \$TOKEN\" https://api.github.com/user | grep x-oauth-scopes' to verify"
