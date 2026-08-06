# Shared environment for all shells.
export PATH="$HOME/.local/bin:$PATH"

# opencode CLI — installed to ~/.opencode/bin by install-extras.sh.
# Guarded so the PATH stays clean on machines where it is not installed.
if [ -d "$HOME/.opencode/bin" ]; then
    PATH="$HOME/.opencode/bin:$PATH"
fi

export PATH="$PATH:/snap/bin"
export AWS_VAULT_BACKEND=file
