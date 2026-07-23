# dotfiles

My personal environment: shell, editor, terminal, window manager, and CLI tooling — managed with [GNU Stow](https://www.gnu.org/software/stow/) and bootstrapped for both **macOS** and **Ubuntu/Linux**.

## Quick restore

On a fresh machine:

```sh
# 1. Install git (macOS: xcode-select --install | Ubuntu: sudo apt install -y git)

# 2. Clone the repo
git clone git@github.com:e-serebriakov/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. Preview what will be symlinked (nothing is changed)
./bootstrap/install.sh -n

# 4. Run the full bootstrap
./bootstrap/install.sh
```

That's it. Open a new shell and the environment is restored.

## What `install.sh` does

`bootstrap/install.sh` is idempotent — safe to re-run any time. It:

1. **Runs the platform bootstrap** (`macos.sh` or `linux.sh`, auto-detected via `uname`):
   - macOS: installs [Homebrew](https://brew.sh) if missing, then `brew bundle` from `bootstrap/Brewfile`.
   - Linux: installs packages via `apt` and vendor repos.
2. **Installs zsh plugins** into `~/.local/share/zsh` (fzf-tab, syntax-highlighting, history-substring-search, autosuggestions).
3. **Symlinks every package** in `packages/` into `$HOME` with `stow`.
4. **Installs runtime tools** declared in `packages/mise/.config/mise/config.toml` via [`mise`](https://mise.jdx.dev).

### Flags & env vars

| What | How |
| --- | --- |
| Dry run (preview symlinks) | `./bootstrap/install.sh -n` or `--dry-run` |
| Context (default `personal`) | `DOTFILES_CONTEXT=work ./bootstrap/install.sh` |

### On the `--adopt` restore step

The stow step runs `stow --adopt -R`. If a real (non-symlink) config file already exists at a target path, `--adopt` pulls it *into* the repo instead of erroring. Immediately after, the script restores `packages/` from git:

```sh
git diff --name-only packages/ | xargs -I{} git checkout -- {}
```

So the repo's tracked version always wins, and any pre-existing config on the machine is replaced by these dotfiles. Uncommitted changes elsewhere (e.g. `Brewfile`) are left untouched.

## Repo layout

```
dotfiles/
├── bootstrap/
│   ├── install.sh      # entry point — orchestrates everything
│   ├── macos.sh        # Homebrew + brew bundle
│   ├── linux.sh        # apt + vendor installs
│   └── Brewfile        # macOS packages (brews + casks + fonts)
└── packages/           # one stow package per tool
    ├── aerospace/      # tiling WM (macOS)
    ├── ccstatusline/   # Claude Code statusline
    ├── claude/         # Claude Code config
    ├── gh-dash/        # gh dashboard
    ├── git/            # git config
    ├── helix/          # helix editor
    ├── karabiner/      # keyboard remapping (macOS)
    ├── markdown/       # markdown lint config
    ├── mise/           # runtime/tool versions
    ├── nvim/           # neovim config
    ├── starship/       # prompt
    ├── wezterm/        # terminal
    ├── zellij/         # terminal multiplexer
    └── zsh/            # .zshrc + shell setup
```

Each folder under `packages/` mirrors the layout of `$HOME`. For example, `packages/nvim/.config/nvim/` stows to `~/.config/nvim/`.

## Managing packages

```sh
# Add / update a single package after editing it
stow -R -d packages -t "$HOME" nvim

# Remove a package's symlinks
stow -D -d packages -t "$HOME" nvim
```

To track a **new** config: create `packages/<name>/` mirroring its path under `$HOME`, move the file in, then re-run `./bootstrap/install.sh`.

## What gets installed

- **CLI**: `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `jq`, `git-delta`, `zoxide`, `stow`, `gh`, `git-town`
- **Editors**: `neovim`, `helix`
- **Shell/prompt**: `zsh` + plugins, `starship`
- **Terminal/WM** (macOS): `wezterm`, `aerospace`, `karabiner-elements`, `raycast`
- **Runtimes** (via mise): `node 24`, `python 3.12`, `uv`, `just`, `lazydocker`, plus npm formatters

See `bootstrap/Brewfile` and `packages/mise/.config/mise/config.toml` for the authoritative lists.

## Requirements

- `git` and a working `curl` (both scripts fetch installers)
- macOS: nothing else — Homebrew is installed automatically
- Linux: `sudo` access (apt + vendor repos)
