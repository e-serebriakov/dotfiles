# dotfiles

My personal environment: shell, editor, terminal, window manager, and CLI tooling — managed with [GNU Stow](https://www.gnu.org/software/stow/) and bootstrapped for both **macOS** and **Ubuntu/Linux**.

## Quick restore

On a fresh machine:

```sh
# 1. Install git (macOS: xcode-select --install | Ubuntu: sudo apt install -y git)

# 2. Clone the repo
# (any location works; install.sh resolves paths relative to itself)
git clone git@github.com:e-serebriakov/dotfiles.git ~/source_code/dotfiles
cd ~/source_code/dotfiles

# 3. Run the full bootstrap
./bootstrap/install.sh
```

That's it. Open a new shell and the environment is restored.

> **SSH keys** need two manual touches on a fresh machine — see [SSH setup](#ssh-setup). Your private `~/.ssh/config` is intentionally **not** tracked here.

## What `install.sh` does

`bootstrap/install.sh` is idempotent — safe to re-run any time. It:

1. **Runs the platform bootstrap** (`macos.sh` or `linux.sh`, auto-detected via `uname`):
   - macOS: installs Homebrew if missing, then runs `brew bundle --no-upgrade` for `bootstrap/Brewfile` (stow, the GUI apps and the font).
   - Linux: installs build essentials and zsh via `apt`, then makes zsh the login shell.

   Then installs [`mise`](https://mise.jdx.dev) the same way on both platforms.
2. **Restores pinned zsh plugins** into `~/.local/share/zsh` (fzf-tab, syntax-highlighting, history-substring-search, autosuggestions). Exact commit IDs live in `bootstrap/install.sh`; reruns do not pull newer commits. Local plugin edits stop setup rather than being overwritten.
3. **Generates the theme files** from `theme/ergo-light.tokens.json` (see [Theme](#theme)) — run before stowing so the symlinks point at fresh output. A token error is non-fatal: it stows anyway and the tools fall back to their defaults.
4. **Symlinks every package** in `packages/` into `$HOME` with `stow`.
5. **Installs runtime tools** declared in `packages/mise/.config/mise/config.toml` via [`mise`](https://mise.jdx.dev). If mise is missing or a tool fails to install, bootstrap exits with a nonzero status and reports setup as incomplete. After resolving the reported error, retry with `mise install --locked`.

### Flags & env vars

| What | How |
| --- | --- |
| Dry run (preview symlinks; needs `stow`, so not on a fresh machine) | `./bootstrap/install.sh -n` or `--dry-run` |
| Context (default `personal`) | `DOTFILES_CONTEXT=work ./bootstrap/install.sh` |

### On the backup step

Before `stow -R`, the script moves any real (non-symlink) file sitting at a target path into `~/.dotfiles-backup/<timestamp>/`, preserving its relative path. Only genuine conflicts move — targets that already resolve back into `packages/` are left alone.

So the repo's tracked version always wins, any pre-existing config on the machine is set aside rather than overwritten, and uncommitted changes under `packages/` are never reverted.

## SSH setup

Your `~/.ssh/config` is **not** tracked — it holds private hosts, tailnet addresses, and tool-managed blocks (OrbStack, DevPod). Only a generic, portable defaults block is versioned, at `packages/ssh/.ssh/config.d/defaults.conf`, which stow links to `~/.ssh/config.d/defaults.conf`. It sets `AddKeysToAgent`, `UseKeychain` (ignored on Linux via `IgnoreUnknown`), and the default identity files.

On a fresh machine, two manual steps wire it up:

1. **Include the tracked defaults** from your real config. Add this line to `~/.ssh/config` (anywhere in global scope, or under a `Host *`):

   ```sshconfig
   Host *
   Include ~/.ssh/config.d/*.conf
   ```

   > Note: an `Include` inherits the surrounding `Host`/`Match` context. Place it in global scope (or under an explicit `Host *`) so it applies to every connection — not accidentally nested inside another host's block.

2. **Load your keys into the agent:**
   - **macOS** — `bootstrap/macos.sh` runs `ssh-add --apple-use-keychain` automatically (prompts for each passphrase once, then Keychain unlocks them). To do it by hand: `ssh-add --apple-use-keychain ~/.ssh/auth ~/.ssh/sign`.
   - **Linux** — `.zshrc` starts one shared `ssh-agent` at `~/.ssh/agent.sock` (guarded to `linux*` only; macOS uses the native Keychain agent instead). Keys are added on first use via `AddKeysToAgent`, so the passphrase prompt comes with your first `ssh`/`git` call, not at shell startup.

The private keys themselves (`~/.ssh/auth`, `~/.ssh/sign`, …) are never in this repo — copy them over securely out of band.

## Repo layout

```
dotfiles/
├── bootstrap/
│   ├── install.sh      # entry point — orchestrates everything
│   ├── macos.sh        # homebrew + brew bundle + ssh keychain
│   ├── linux.sh        # apt essentials
│   └── Brewfile        # the macOS-only bare minimum: stow + casks
├── theme/              # design tokens + generator (see Theme)
│   ├── ergo-light.tokens.json  # the single source of colour
│   ├── engine.clj              # token graph + tokens↔generator contract
│   ├── generators/             # one namespace per tool; adapters vector
│   └── generate.clj            # CLI: tokens → per-tool theme files
└── packages/           # one stow package per tool
    ├── aerospace/      # tiling WM (macOS)
    ├── ccstatusline/   # Claude Code statusline
    ├── claude/         # Claude Code config
    ├── git/            # git config
    ├── helix/          # helix editor
    ├── karabiner/      # keyboard remapping (macOS)
    ├── markdown/       # markdown lint config
    ├── mise/           # runtime/tool versions
    ├── nvim/           # neovim config
    ├── ssh/            # generic SSH defaults (~/.ssh/config.d) — see SSH setup
    ├── starship/       # prompt
    ├── wezterm/        # terminal
    ├── zellij/         # terminal multiplexer
    └── zsh/            # .zshrc + .zshenv + shell setup
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

## Deliberate updates

Bootstrap restores the committed mise lockfile and shell-plugin revisions.
Theme generation also uses the locked Babashka version, reading the repo's mise
configuration before Stow installs it.

To update a CLI tool (run from the repo root):

```sh
MISE_GLOBAL_CONFIG_FILE="$PWD/packages/mise/.config/mise/config.toml" mise lock --global --bump babashka
git diff -- packages/mise/.config/mise/mise.lock
./bootstrap/install.sh
```

Replace `babashka` with another tool name, or omit it to update all tools within
their configured version ranges. Review and commit the lockfile after testing.

To update a shell plugin, find its upstream commit, replace that plugin's full
commit ID in the `PLUGINS` block in `bootstrap/install.sh`, and rerun bootstrap:

```sh
git ls-remote https://github.com/Aloxaf/fzf-tab HEAD
```

Test the updated plugin in a new shell before committing the revision change.

Homebrew apps and Ubuntu packages remain distribution-managed, not version
locked. Homebrew setup skips routine upgrades of installed apps, though installing
missing dependencies can still require upgrades. To explicitly update the Brewfile:

```sh
brew bundle --upgrade --file bootstrap/Brewfile
```

## Theme

All colour comes from **one file** — `theme/ergo-light.tokens.json` — tool-agnostic [design tokens](https://tr.designtokens.org/) in two layers: raw OKLCH ramps (*primitives*) aliased into named roles (*semantic*: `accent.string`, `diff.add`, `status.error`, …). No tool reads it directly.

`theme/generate.clj` translates the semantic tokens into each tool's own format via small per-tool *generators* (`theme/generators/`), emitting five files:

| Tool | Generated file |
| --- | --- |
| Neovim | `colorschemes/ergo_light_palette.lua` |
| WezTerm | `colors/ergo_light.toml` |
| Zellij | `themes/ergo-light.kdl` |
| delta (git diffs) | `delta/ergo-light.gitconfig` |
| Helix | `themes/ergo_light.toml` |

Those outputs are **gitignored build artifacts** — never hand-edit them; they're regenerated on every `install.sh`.

```sh
# Change the theme: edit theme/ergo-light.tokens.json, then
(cd theme && bb -m generate)       # rewrites the five files (install.sh also does this)
```

Reload the tool and the whole environment re-tunes together.

**Add a tool:** drop a `theme/generators/<tool>.clj` (exposing `render`), register it in the `adapters` vector in `generate.clj`, and gitignore its output. A contract test guards that generators only reference tokens that exist:

```sh
(cd theme && bb -m generate && bb test)
```

Tools that aren't generated (ccstatusline, starship, git's own output) use **named ANSI colours**, so they follow the terminal palette — itself themed from these tokens — automatically.

## What gets installed

Most command-line tools come from `mise`, so macOS and Linux install the same list.
Ubuntu's bootstrap prerequisites and zsh come from `apt`.

- **CLI**: `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `jq`, `delta`, `zoxide`, `gh`, `git-town`, `direnv`, `bottom`, `k9s`, `rainfrog`
- **Editors**: `neovim`, `helix`
- **Shell/prompt**: `zsh` + plugins, `starship`
- **Runtimes**: `node 24`, `python 3.12`, `uv`, `just`, `lazydocker`, plus npm formatters
- **Linters**: `shellcheck`, `actionlint`, `markdownlint-cli2`
- **Agents**: `claude-code`, `codex`
- **Apps** (macOS, via `bootstrap/Brewfile`): `wezterm`, `aerospace`, `karabiner-elements`, `raycast`, `orbstack`, `secretive`, JetBrains Mono Nerd Font

Homebrew stays for the handful of things mise can't do: macOS app bundles, the font, and GNU Stow (a Perl program with no release binary and no mise registry entry).

See `packages/mise/.config/mise/config.toml` for the authoritative tool list.

## Requirements

- `git` and a working `curl` (both scripts fetch installers)
- Babashka (`bb`) generates the theme files; bootstrap fetches it through mise before stowing, so no manual installation is needed.
- macOS: `sudo` access — the Homebrew installer and the Karabiner-Elements cask both need it
- Linux: `sudo` access (apt)
