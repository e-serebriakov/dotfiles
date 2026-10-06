# dotfiles

Personal shell, editor, terminal, window manager, and command-line configuration for macOS and Ubuntu.
[GNU Stow](https://www.gnu.org/software/stow/) manages the configuration files.

## Quick restore

On a new machine:

1. Install Git: `xcode-select --install` on macOS or `sudo apt install -y git` on Ubuntu.
2. Set up SSH access to GitHub before using the SSH clone command below. See [SSH setup](#ssh-setup).
3. Clone the repository and run the setup script. You can clone into any directory; the script resolves its own paths.

```sh
git clone git@github.com:e-serebriakov/dotfiles.git ~/source_code/dotfiles
cd ~/source_code/dotfiles
./bootstrap/install.sh
```

Open a new shell to use the configuration.

## What `install.sh` does

You can safely run `bootstrap/install.sh` again. It:

1. Detects the operating system with `uname` and runs `macos.sh` or `linux.sh`:
   - macOS: installs Homebrew if needed, then runs `brew bundle --no-upgrade` with `bootstrap/Brewfile`.
     This installs Stow, the applications, and the font.
   - Ubuntu: installs required packages and zsh with `apt`, then sets zsh as the login shell.
   - Both platforms: installs [mise](https://mise.jdx.dev) if needed.
2. Restores zsh plugins in `~/.local/share/zsh`: fzf-tab, syntax-highlighting, history-substring-search, and autosuggestions.
   It uses the commit IDs in `bootstrap/install.sh`. It does not fetch newer revisions or overwrite local plugin changes.
   Local changes stop setup.
3. Generates theme files from the active theme in `theme/` before Stow creates the symbolic links.
   If generation fails, setup continues. Tools use default colors when generated files are unavailable.
4. Uses Stow to create symbolic links from `$HOME` to the packages in `packages/`.
5. Uses mise to install the tools in `packages/mise/.config/mise/config.toml`.
   If mise is missing or installation fails, setup reports the error and exits with a nonzero status.
   Correct the error, then run `mise install --locked`. If mise was missing, install it and run setup again.

### Options and environment variables

| Purpose | Command |
| --- | --- |
| Preview symbolic links without installing tools; requires Stow | `./bootstrap/install.sh -n` or `--dry-run` |
| Set the context (default: `personal`) | `DOTFILES_CONTEXT=work ./bootstrap/install.sh` |

### Backups

Before `stow -R`, the script moves conflicting files or symbolic links to `~/.dotfiles-backup/<timestamp>/`.
It preserves their relative paths and keeps links that already point to the package files.
It skips backup paths that pass through a symbolic link to a directory outside `packages/`.

The package files replace the conflicting configuration. The script preserves uncommitted changes in `packages/`.

## SSH setup

Keep private hosts, tailnet addresses, and tool-managed sections (OrbStack, DevPod) in `~/.ssh/config`.
This file is not tracked.

Stow links `packages/ssh/.ssh/config.d/defaults.conf` to `~/.ssh/config.d/defaults.conf`.
These shared defaults set `AddKeysToAgent`, `UseKeychain`, and the identity files.
`IgnoreUnknown` lets Linux ignore `UseKeychain`.

On a new machine:

1. Copy your private keys (`~/.ssh/auth`, `~/.ssh/sign`, and any others) through a secure channel.
   Private keys are not stored in this repository.
2. Add the defaults to `~/.ssh/config`:

   ```sshconfig
   Host *
   Include ~/.ssh/config.d/*.conf
   ```

   `Include` inherits the surrounding `Host` or `Match` context.
   Place it in global scope or under `Host *` so it applies to all connections.
3. Load the keys:
   - macOS: `bootstrap/macos.sh` runs `ssh-add --apple-use-keychain` automatically.
     It requests each passphrase once, then Keychain unlocks the keys.
     To load them manually, run `ssh-add --apple-use-keychain ~/.ssh/auth ~/.ssh/sign`.
   - Linux: `.zshrc` starts a shared `ssh-agent` at `~/.ssh/agent.sock` if no agent socket is available.
     `AddKeysToAgent` adds keys on first use. The passphrase prompt appears with the first SSH or Git command, not at shell startup.
     macOS uses its native Keychain agent.

## Repository layout

```text
dotfiles/
├── bootstrap/
│   ├── install.sh      # Main setup script
│   ├── macos.sh        # Homebrew, applications, and SSH Keychain setup
│   ├── linux.sh        # Required Ubuntu packages
│   └── Brewfile        # Stow, macOS applications, and font
├── theme/              # Design tokens and generators; see theme/README.md
│   ├── ergo-light.tokens.json  # Default theme colors
│   ├── te-calm.tokens.json     # Teenage Engineering-inspired theme
│   ├── engine.clj              # Token resolution and generator validation
│   ├── generators/             # One namespace per tool
│   └── generate.clj            # Theme generation command
└── packages/           # One Stow package per tool
    ├── aerospace/      # Tiling window manager (macOS)
    ├── ccstatusline/   # Claude Code status line
    ├── claude/         # Claude Code configuration
    ├── git/            # Git configuration
    ├── helix/          # Helix editor
    ├── karabiner/      # Keyboard remapping (macOS)
    ├── markdown/       # Markdown lint configuration
    ├── mise/           # Tool and runtime versions
    ├── nvim/           # Neovim configuration
    ├── ssh/            # Shared SSH defaults
    ├── starship/       # Shell prompt
    ├── wezterm/        # Terminal
    ├── zellij/         # Terminal multiplexer
    └── zsh/            # Shell configuration
```

Each directory in `packages/` matches the layout of `$HOME`.
For example, Stow links `packages/nvim/.config/nvim/` to `~/.config/nvim/`.

## Manage packages

```sh
# Create or update the symbolic links for one package.
stow -R -d packages -t "$HOME" nvim

# Remove the symbolic links for one package.
stow -D -d packages -t "$HOME" nvim
```

To track a new configuration:

1. Create `packages/<name>/` with the same directory layout as `$HOME`.
2. Move the configuration file into that directory.
3. Run `./bootstrap/install.sh` again.

## Update tools

Setup uses the committed mise lockfile and zsh plugin revisions.
Theme generation uses the locked Babashka version from the repository's mise configuration before Stow links it.

To update a command-line tool, run these commands from the repository root:

```sh
MISE_GLOBAL_CONFIG_FILE="$PWD/packages/mise/.config/mise/config.toml" mise lock --global --bump babashka
git diff -- packages/mise/.config/mise/mise.lock
./bootstrap/install.sh
```

Replace `babashka` with another tool name, or omit it to update all tools within their configured version ranges.
Test the tools, then review and commit the lockfile.

To update a zsh plugin:

1. Find its upstream commit. For example:

   ```sh
   git ls-remote https://github.com/Aloxaf/fzf-tab HEAD
   ```

2. Replace its full commit ID in the `PLUGINS` block in `bootstrap/install.sh`.
3. Run setup again.
4. Test the plugin in a new shell before committing the change.

Homebrew applications and Ubuntu packages do not use version locks.
Setup skips routine Homebrew upgrades, but missing dependencies can require upgrades.
To upgrade packages listed in the Brewfile:

```sh
brew bundle --upgrade --file bootstrap/Brewfile
```

## Theme

Each `theme/*.tokens.json` file defines one theme for Neovim, WezTerm, Zellij, delta, and Helix: `ergo-light` (the default) and `te-calm`.
Setup generates the active theme into files named `baked` that each tool loads. Git ignores these files; do not edit them manually.

To switch themes, or to apply edits to a token file, run:

```sh
(cd theme && bb -m generate --theme te-calm)  # switch; the choice is remembered
(cd theme && bb -m generate)                  # regenerate the active theme
```

Reload each tool to apply the new colors.
See the [theme guide](theme/README.md) for token structure, generated files, previews, tests, and instructions to add a tool.

## Installed tools

mise provides the same command-line tools on macOS and Linux.
Ubuntu uses `apt` for setup requirements and zsh.

- **Command-line tools:** `fzf`, `ripgrep`, `fd`, `bat`, `eza`, `jq`, `delta`, `zoxide`, `gh`, `git-town`, `direnv`, `bottom`, `k9s`, `rainfrog`
- **Editors:** `neovim`, `helix`
- **Shell and prompt:** `zsh`, plugins, `starship`
- **Runtimes and development tools:** `node 24`, `python 3.12`, `uv`, `just`, `lazydocker`, npm formatters
- **Linters:** `shellcheck`, `actionlint`, `markdownlint-cli2`
- **Agents:** `claude-code`, `codex`
- **macOS applications:** `wezterm`, `aerospace`, `karabiner-elements`, `raycast`, `orbstack`, `secretive`

Homebrew installs the macOS applications, JetBrains Mono Nerd Font, and GNU Stow from `bootstrap/Brewfile`.
Stow uses Perl and has no release binary or mise registry entry.
See `packages/mise/.config/mise/config.toml` for the complete mise tool list.

## Requirements

- Git and curl to download the repository and installers.
- macOS: `sudo` access for Homebrew installation and Karabiner-Elements.
- Ubuntu: `sudo` access for `apt` and the login shell change.

Setup installs Babashka (`bb`) through mise before theme generation. No manual Babashka installation is needed.
