#!/usr/bin/env bash
# Node 22: keep npm 10.9.x (bundled or corepack-pinned). Re-pin 10.9.3 if npm 11 was activated.
# Node 24+: no changes (often ships npm 11).

set -u

log()  { printf '[npm] %s\n' "$*"; }
warn() { printf '[npm] WARNING: %s\n' "$*" >&2; }

TARGET_NPM="${NPM_COREPACK_VERSION:-10.9.3}"
FNM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fnm/node-versions"

version_major() {
  echo "$1" | cut -d. -f1
}

if [ ! -d "$FNM_DIR" ]; then
  log "fnm node-versions not found, skipping npm policy check"
  exit 0
fi

for node_dir in "$FNM_DIR"/*/installation; do
  [ -d "$node_dir" ] || continue

  version_name="$(basename "$(dirname "$node_dir")")"
  case "$version_name" in
    v22.*)
      corepack="$node_dir/bin/corepack"
      npm_bin="$node_dir/bin/npm"
      if [ ! -x "$corepack" ]; then
        warn "Node ${version_name}: corepack missing, skipping"
        continue
      fi

      "$corepack" enable 2>/dev/null || true

      current="0"
      if [ -x "$npm_bin" ]; then
        current="$("$npm_bin" -v 2>/dev/null || echo 0)"
      fi

      major="$(version_major "$current")"
      if [ "$major" = "10" ]; then
        log "Node ${version_name}: npm ${current} (ok)"
        continue
      fi

      log "Node ${version_name}: pinning npm@${TARGET_NPM} (was ${current})"
      if "$corepack" prepare "npm@${TARGET_NPM}" --activate 2>/dev/null; then
        log "Node ${version_name}: npm $("$npm_bin" -v 2>/dev/null || echo '?')"
      else
        warn "Node ${version_name}: corepack prepare npm@${TARGET_NPM} failed"
      fi
      ;;
    v24.*)
      log "Node ${version_name}: left as-is (npm 11 lane)"
      ;;
    *)
      log "Node ${version_name}: no npm policy applied"
      ;;
  esac
done

exit 0
