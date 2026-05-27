#!/usr/bin/env bash
# WSL-Hello-sudo: biometric sudo for WSL. No-op on Linux/macOS (not WSL).
# https://github.com/nullpo-head/WSL-Hello-sudo

set -euo pipefail

if ! grep -qi microsoft /proc/version 2>/dev/null; then
	exit 0
fi

EXTRACT_PARENT="${HOME}/.local/share/wsl-hello-sudo-dist"
ARCHIVE="${EXTRACT_PARENT}/release.tar.gz"

mkdir -p "${EXTRACT_PARENT}"
cd "${EXTRACT_PARENT}"

# Upstream tarball contains a top-level directory (typically ./release/).
if ls -d */ >/dev/null 2>&1; then
	exit 0
fi

wget -q "https://github.com/nullpo-head/WSL-Hello-sudo/releases/latest/download/release.tar.gz" \
	-O "${ARCHIVE}"
tar xf "${ARCHIVE}"
rm -f "${ARCHIVE}"
