#!/usr/bin/env bash
# Optional install extras, run by dotbot as a single non-fatal shell task.
# Every section is guarded so a missing privilege, package manager, network
# or already-installed tool never aborts the install: dotbot skips the rest
# of the shell block after the first failing command, so a failed `sudo apt`
# used to take down oh-my-zsh, fnm, gitconfig-work and SSH signing with it.
# This script always exits 0; problems are reported as warnings.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log()  { printf '[extras] %s\n' "$*"; }
warn() { printf '[extras] WARNING: %s\n' "$*" >&2; }
skip() { log "SKIP: $*"; }
has()  { command -v "$1" >/dev/null 2>&1; }

apt_install() { # $@ = packages
  if ! has sudo || ! has apt-get; then
    skip "apt packages ($*): no sudo/apt-get available"
    return 0
  fi
  if sudo apt-get install -y "$@" >/dev/null 2>&1; then
    log "apt: installed $*"
  else
    warn "apt: could not install $* (continuing)"
  fi
}

# --- gitconfig-work ----------------------------------------------------------
# Must run before dotbot links ~/.gitconfig-work (the repo file is gitignored
# and created here if missing).
if bash "${ROOT}/scripts/ensure-gitconfig-work.sh"; then
  log "gitconfig-work: ensured"
else
  warn "gitconfig-work: could not be ensured (continuing)"
fi

# --- Oh My Zsh + Powerlevel10k + plugins ------------------------------------
if bash "${ROOT}/scripts/ensure-oh-my-zsh-and-plugins.sh"; then
  log "oh-my-zsh: ensured"
else
  warn "oh-my-zsh: could not be ensured (continuing)"
fi

# --- WSL Hello sudo (no-op outside WSL) --------------------------------------
if bash "${ROOT}/scripts/install-wsl-hello-sudo.sh"; then
  log "wsl-hello-sudo: ok"
else
  warn "wsl-hello-sudo: failed (continuing)"
fi

# --- System packages (best effort, needs sudo) --------------------------------
if ! has sudo || ! has apt-get; then
  skip "system packages: no sudo/apt-get available"
else
  sudo apt-get update -qq >/dev/null 2>&1 \
    && log "apt: updated" \
    || warn "apt: update failed (continuing)"
  apt_install zsh openssh-client curl wget
  apt_install git-core
  apt_install git-lfs
  if has zsh && has sudo; then
    if sudo chsh -s "$(command -v zsh)" "$(id -un)" >/dev/null 2>&1; then
      log "chsh: default shell set to zsh"
    else
      warn "chsh: could not change default shell (continuing)"
    fi
  else
    skip "chsh: zsh not available"
  fi
fi

if has git-lfs; then
  git lfs install >/dev/null 2>&1 \
    && log "git-lfs: hooks installed" \
    || warn "git-lfs: hooks could not be installed (continuing)"
else
  skip "git-lfs: binary not available"
fi

# --- fnm ----------------------------------------------------------------------
if has fnm; then
  skip "fnm: already installed"
else
  if curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell; then
    log "fnm: installed"
  else
    warn "fnm: install failed (continuing)"
  fi
fi

# --- opencode -----------------------------------------------------------------
if [ -x "$HOME/.opencode/bin/opencode" ]; then
  skip "opencode: already installed"
else
  if curl -fsSL https://opencode.ai/install | bash; then
    log "opencode: installed"
  else
    warn "opencode: install failed (continuing)"
  fi
fi

# --- npm GitHub Packages -------------------------------------------------------
if bash "${ROOT}/scripts/setup-npm-github-packages.sh"; then
  log "npm: GitHub Packages configured"
else
  warn "npm: GitHub Packages setup failed (continuing)"
fi

# --- GitHub CLI ---------------------------------------------------------------
# Static binary from the official releases (the Debian/Ubuntu apt package is
# either missing or years behind), falling back to apt when downloads fail.
if has gh; then
  skip "gh: already installed"
else
  _arch="$(uname -m)"
  case "$_arch" in
    x86_64)      _gh_arch="amd64" ;;
    aarch64|arm64) _gh_arch="arm64" ;;
    *)           _gh_arch="" ;;
  esac
  _gh_ok=1
  if [ -n "$_gh_arch" ]; then
    _gh_ver="$(curl -fsSI https://github.com/cli/cli/releases/latest \
      | grep -oP 'tag/\K[^[:space:]]+' | tr -d '\r' | sed 's/^v//')"
    if [ -n "$_gh_ver" ] \
      && curl -fsSL "https://github.com/cli/cli/releases/download/v${_gh_ver}/gh_${_gh_ver}_linux_${_gh_arch}.tar.gz" \
           -o /tmp/gh.tar.gz; then
      tar xzf /tmp/gh.tar.gz -C /tmp
      mkdir -p "$HOME/.local/bin"
      install -m 755 "/tmp/gh_${_gh_ver}_linux_${_gh_arch}/bin/gh" "$HOME/.local/bin/gh"
      rm -rf /tmp/gh.tar.gz "/tmp/gh_${_gh_ver}_linux_${_gh_arch}"
      log "gh: installed ${_gh_ver} (static binary)"
      _gh_ok=0
    fi
  fi
  if [ "$_gh_ok" -eq 1 ]; then
    apt_install gh
  fi
fi

# --- gh stack extension (stacked PRs) ----------------------------------------
if has gh || [ -x "$HOME/.local/bin/gh" ]; then
  _gh_bin="$(command -v gh 2>/dev/null || echo "$HOME/.local/bin/gh")"
  # Remove stale duplicate 'stack' extension dir (leftover from manual install)
  if [ -d "$HOME/.local/share/gh/extensions/stack" ]; then
    rm -rf "$HOME/.local/share/gh/extensions/stack" \
      && log "gh-stack: removed stale 'stack' extension directory" \
      || warn "gh-stack: could not remove stale 'stack' directory (continuing)"
  fi
  # Check if gh is authenticated (via hosts.yml or GH_TOKEN)
  if "$_gh_bin" auth status >/dev/null 2>&1; then
    if "$_gh_bin" extension list 2>/dev/null | grep -q 'github/gh-stack'; then
      skip "gh-stack: already installed"
    else
      if "$_gh_bin" extension install github/gh-stack 2>/dev/null; then
        log "gh-stack: installed"
      else
        warn "gh-stack: install failed (continuing)"
      fi
    fi
  else
    warn "gh-stack: gh not authenticated, skipping extension install (run 'gh auth login' first)"
  fi
else
  skip "gh-stack: gh not available"
fi
