#!/usr/bin/env bash
# Idempotent Oh My Zsh + Powerlevel10k + common plugins.
# Uses KEEP_ZSHRC=yes: dotfiles link ~/.zshrc after this step, so we never replace it here.

set -euo pipefail

ZSH_DIR="${HOME}/.oh-my-zsh"
INSTALL_URL="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

if [[ ! -d "${ZSH_DIR}" ]]; then
	# "" makes $1=--unattended inside the downloaded script (see upstream install.sh header).
	RUNZSH=no CHSH=no KEEP_ZSHRC=yes OVERWRITE_CONFIRMATION=no \
		sh -c "$(curl -fsSL "${INSTALL_URL}")" "" --unattended
fi

mkdir -p "${ZSH_DIR}/custom/themes" "${ZSH_DIR}/custom/plugins"

[[ -d "${ZSH_DIR}/custom/themes/powerlevel10k" ]] \
	|| git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_DIR}/custom/themes/powerlevel10k"

[[ -d "${ZSH_DIR}/custom/plugins/zsh-autosuggestions" ]] \
	|| git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_DIR}/custom/plugins/zsh-autosuggestions"

[[ -d "${ZSH_DIR}/custom/plugins/zsh-syntax-highlighting" ]] \
	|| git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_DIR}/custom/plugins/zsh-syntax-highlighting"
