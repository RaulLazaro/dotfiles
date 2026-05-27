#!/usr/bin/env bash
# Real file: <dotfiles>/gitconfig-work (gitignored). ~/.gitconfig-work is a symlink via dotbot.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${ROOT}/gitconfig-work"

if [[ -f "${TARGET}" ]]; then
	exit 0
fi

if [[ -f "${HOME}/.gitconfig-work" && ! -L "${HOME}/.gitconfig-work" ]]; then
	mv "${HOME}/.gitconfig-work" "${TARGET}"
	exit 0
fi

cp "${ROOT}/gitconfig-work.example" "${TARGET}"
