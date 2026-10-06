#!/usr/bin/env bash
# Upgrade npm via corepack only when the bundled version is too old.
# allow-git and min-release-age in ~/.npmrc require npm >= 11.10.
# Node 24+ already ships npm 11.x — do not pin or downgrade those installs.

set -u

log()  { printf '[npm] %s\n' "$*"; }
warn() { printf '[npm] WARNING: %s\n' "$*" >&2; }

MIN_REQUIRED_NPM="${NPM_MIN_VERSION:-11.10.0}"
TARGET_NPM="${NPM_COREPACK_VERSION:-11.21.0}"
FNM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fnm/node-versions"

version_gte() {
  # True when $1 >= $2 (semver, numeric dot-separated segments).
  printf '%s\n%s\n' "$2" "$1" | sort -C -V
}

if [ ! -d "$FNM_DIR" ]; then
  skip_msg="fnm node-versions not found, skipping corepack npm setup"
  log "$skip_msg"
  exit 0
fi

configured=0
skipped=0

for node_dir in "$FNM_DIR"/*/installation; do
  [ -d "$node_dir" ] || continue

  corepack="$node_dir/bin/corepack"
  npm_bin="$node_dir/bin/npm"

  if [ ! -x "$corepack" ] || [ ! -x "$npm_bin" ]; then
    continue
  fi

  version_name="$(basename "$(dirname "$node_dir")")"
  current_npm="$("$npm_bin" -v 2>/dev/null || echo "0")"

  if version_gte "$current_npm" "$MIN_REQUIRED_NPM"; then
    log "skip: Node ${version_name} already has npm ${current_npm} (>= ${MIN_REQUIRED_NPM})"
    skipped=$((skipped + 1))
    continue
  fi

  log "corepack: npm@${TARGET_NPM} for Node ${version_name} (was ${current_npm})"

  "$corepack" enable 2>/dev/null || warn "corepack enable failed for ${version_name}"
  "$corepack" prepare "npm@${TARGET_NPM}" --activate 2>/dev/null \
    || warn "corepack prepare failed for ${version_name}"

  configured=$((configured + 1))
done

if [ "$configured" -eq 0 ] && [ "$skipped" -eq 0 ]; then
  warn "no fnm Node installations found for corepack setup"
elif [ "$configured" -eq 0 ]; then
  log "corepack: nothing to upgrade (${skipped} Node version(s) already meet npm >= ${MIN_REQUIRED_NPM})"
else
  log "corepack: upgraded ${configured} Node version(s); skipped ${skipped}"
fi

exit 0
