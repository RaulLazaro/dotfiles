#!/usr/bin/env bash
# Ensures ~/.ssh/id_ed25519 exists (matches gitconfig signingkey) and maintains
# ~/.ssh/allowed_signers with personal + work emails for SSH commit signatures.
#
# Personal email comes from tracked gitconfig; work email from ~/.gitconfig-work
# when present and not left as the example placeholder.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GITCONFIG_TRACKED="${ROOT}/gitconfig"
WORK_GITCONFIG="${HOME}/.gitconfig-work"
SSH_DIR="${HOME}/.ssh"
KEY="${SSH_DIR}/id_ed25519"
ALLOWED="${SSH_DIR}/allowed_signers"

MARK_BEGIN="# BEGIN dotfiles-managed git signing"
MARK_END="# END dotfiles-managed git signing"

mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

if [[ ! -f "${KEY}" ]]; then
	PERSONAL_EMAIL_FOR_COMMENT="$(git config --file "${GITCONFIG_TRACKED}" user.email)"
	ssh-keygen -t ed25519 -f "${KEY}" -N "" -C "${PERSONAL_EMAIL_FOR_COMMENT}"
fi

PERSONAL_EMAIL="$(git config --file "${GITCONFIG_TRACKED}" user.email)"
KEYTYPE="$(awk '{print $1}' "${KEY}.pub")"
KEYDATA="$(awk '{print $2}' "${KEY}.pub")"
KEY_BODY="${KEYTYPE} ${KEYDATA}"

WORK_EMAIL=""
if [[ -f "${WORK_GITCONFIG}" ]]; then
	WORK_EMAIL="$(git config --file "${WORK_GITCONFIG}" user.email 2>/dev/null || true)"
fi
if [[ -z "${WORK_EMAIL}" ]] || [[ "${WORK_EMAIL}" == *YOUR_WORK_EMAIL* ]]; then
	WORK_EMAIL=""
fi

TMP="$(mktemp)"
trap 'rm -f "${TMP}"' EXIT

if [[ -f "${ALLOWED}" ]]; then
	awk -v begin="${MARK_BEGIN}" -v end="${MARK_END}" '
		$0 == begin { skip = 1; next }
		$0 == end { skip = 0; next }
		!skip { print }
	' "${ALLOWED}" >"${TMP}"
else
	: >"${TMP}"
fi

{
	echo "${MARK_BEGIN}"
	echo "${PERSONAL_EMAIL} ${KEY_BODY}"
	if [[ -n "${WORK_EMAIL}" && "${WORK_EMAIL}" != "${PERSONAL_EMAIL}" ]]; then
		echo "${WORK_EMAIL} ${KEY_BODY}"
	fi
	echo "${MARK_END}"
} >>"${TMP}"

mv "${TMP}" "${ALLOWED}"
trap - EXIT
chmod 644 "${ALLOWED}"
