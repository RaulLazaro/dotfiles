#!/usr/bin/env bash
# Set up npm for GitHub Packages (@raullazaro scope).
# Uses SSH for reading (no token needed for private repos with SSH access).
# Token with write:packages scope is only needed for publishing.

set -u

log()  { printf '[npm] %s\n' "$*"; }
warn() { printf '[npm] WARNING: %s\n' "$*" >&2; }

NPMRC="$HOME/.npmrc"

# Write ~/.npmrc — SSH handles auth for reads, no token needed
cat > "$NPMRC" <<'EOF'
# GitHub Packages — @raullazaro scope
# Reads via SSH (no token needed), publish requires token with write:packages
@raullazaro:registry=https://npm.pkg.github.com
# For publishing, set token: npm config set //npm.pkg.github.com/:_authToken YOUR_TOKEN
EOF

log "wrote $NPMRC with GitHub Packages registry"
log "install: npm install @raullazaro/paper-cutout-shader (uses SSH)"
log "publish: set token first with 'npm config set //npm.pkg.github.com/:_authToken YOUR_TOKEN'"
