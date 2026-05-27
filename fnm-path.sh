# fnm: stable Node/npm on PATH for all shells.
# Uses the default alias path instead of fnm multishell (/run/user/...),
# which is not available in restricted environments (e.g. Cursor agent sandbox).
FNM_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/fnm"
FNM_DEFAULT_BIN="$FNM_DIR/aliases/default/bin"

if [ -d "$FNM_DEFAULT_BIN" ]; then
  PATH="$FNM_DEFAULT_BIN:$PATH"
fi
if [ -d "$FNM_DIR" ]; then
  PATH="$FNM_DIR:$PATH"
fi
export PATH
