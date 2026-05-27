# Dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot).

## Install

```zsh
git clone https://github.com/RaulLazaro/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install
./install
```

On first install, `gitconfig-work` is created **inside your dotfiles clone** (from
`gitconfig-work.example` if needed), and `~/.gitconfig-work` is a **symlink** to that file.
The file is listed in `.gitignore` so it is never committed. Edit it with your work email.

If you still have a **plain file** at `~/.gitconfig-work` from an older setup, `./install` moves it
once into `gitconfig-work` in the repo, then replaces the home path with the symlink.

## What gets linked

| File in `$HOME` | Source |
| ----- | ------ |
| `~/.zshrc` | `zshrc` |
| `~/.zshenv` | `zshenv` |
| `~/.bashrc` | `bashrc` |
| `~/.profile` | `profile` |
| `~/.gitconfig` | `gitconfig` |
| `~/.gitconfig-work` | `gitconfig-work` |
| `~/.p10k.zsh` | `p10k.zsh` |

| File in `$HOME` | Source | Notes |
| ----- | ------ | ------ |
| Work git include | `scripts/ensure-gitconfig-work.sh` | Repo file `gitconfig-work` (gitignored); migrates old plain `~/.gitconfig-work` |
| Oh My Zsh stack | `scripts/ensure-oh-my-zsh-and-plugins.sh` | Idempotent; see **Re-run install** |
| WSL Hello sudo | `scripts/install-wsl-hello-sudo.sh` | WSL only; see **Re-run install** |
| SSH git signing | `scripts/bootstrap-git-ssh-signing.sh` | Runs on `./install`; see below |

## SSH key and `allowed_signers`

On each `./install`, `scripts/bootstrap-git-ssh-signing.sh` runs after symlinks are in place:

- Creates `~/.ssh/id_ed25519` (and `.pub`) if missing — same path as `user.signingkey` in `gitconfig`.
- Maintains a **marked block** in `~/.ssh/allowed_signers` with:
  - your personal email from the tracked `gitconfig`, and
  - your work email from `~/.gitconfig-work`, when set and not still the `YOUR_WORK_EMAIL@example.com` placeholder.

Lines you add **outside** that block are left as-is. Re-run `./install` after changing your work email so the block is refreshed.

### SSH commit signing

Git is configured for SSH signatures (`gpg.format = ssh`,
`allowedSignersFile = ~/.ssh/allowed_signers`).
You do not need to maintain `allowed_signers` by hand unless you use extra identities;
the install script keeps personal + work in sync with your keys.

If you add GitHub as a signing key, upload `~/.ssh/id_ed25519.pub` in GitHub **SSH keys** and enable
**vigilant mode** / signature verification as you prefer.

## Shared scripts

- `fnm-path.sh` — stable Node/npm on PATH (fnm default alias)
- `env.sh` — shared env vars (`AWS_VAULT_BACKEND`, PATH)

Sourced from `zshenv` (every zsh), `profile` (login shells), and `bashrc` (interactive bash).

## Git identity (work vs personal)

- **Default (personal):** `contact@raullazaro.com` in `gitconfig`
- **Work:** email in `~/.gitconfig-work` (local), auto-applied inside `~/work/`.
  `./install` refreshes `~/.ssh/allowed_signers` for that email (see above).

```zsh
# Same file via symlink — path in the clone is convenient in the IDE
${EDITOR:-cursor} ~/dotfiles/gitconfig-work

cd ~/work/your-repo && git config user.email
```

### Work repos layout

Keep all work repositories under `~/work/`:

```zsh
mkdir -p ~/work
mv ~/influencity ~/work/influencity   # one-time migration
```

## Re-run install

`./install` is safe to re-run: dotbot updates symlinks and re-runs shell tasks.
The work git file `gitconfig-work` in your clone is **not** overwritten if it exists; adjust the symlink
when you change clone path.
Some tasks (oh-my-zsh, fnm, etc.) may fail if already installed — that is expected.

The Oh My Zsh step runs `scripts/ensure-oh-my-zsh-and-plugins.sh` (idempotent: skips install if
`~/.oh-my-zsh` exists, clones themes/plugins only when missing).
It uses the upstream form `sh -c "$(curl …)" "" --unattended` and `KEEP_ZSHRC=yes` so your `~/.zshrc`
is not replaced here; dotfiles `link` supplies `zshrc` afterward.

WSL Hello sudo is handled by `scripts/install-wsl-hello-sudo.sh` (no-op outside WSL; extracts once
under `~/.local/share/wsl-hello-sudo-dist/` — finish setup from the unpacked directory if you use it).

If your dotfiles live somewhere other than `~/dotfiles`, set `DOTFILES_DIR` before starting a shell
(e.g. in `~/.profile`) so `fnm-path.sh` and `env.sh` load from the right place.
