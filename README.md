# dotfiles

Personal shell, editor, terminal, and window manager configuration for Apple Silicon macOS and Ubuntu.
[GNU Stow](https://www.gnu.org/software/stow/) links files from `packages/` into `$HOME`.

## Install

You need Git and `sudo` access.
The macOS script expects Homebrew at `/opt/homebrew`.
Before you clone through SSH, configure [GitHub SSH access](docs/setup.md#ssh-access).

1. Install Git: `xcode-select --install` on macOS or `sudo apt install -y git` on Ubuntu.
2. Clone the repository:

   ```sh
   git clone git@github.com:e-serebriakov/dotfiles.git ~/source_code/dotfiles
   ```

3. Go to the repository directory:

   ```sh
   cd ~/source_code/dotfiles
   ```

4. Run setup:

   ```sh
   ./bootstrap/install.sh
   ```

5. Open a new shell.

Setup installs platform packages, mise tools, and pinned zsh plugins.
It generates the active theme and creates the Stow symbolic links.
Conflicting files move to `~/.dotfiles-backup/<timestamp>/`.
Local changes to managed zsh plugins stop setup.
See [setup details](docs/setup.md) for SSH defaults, backup behavior, and error recovery.

To preview the symbolic links, use `./bootstrap/install.sh --dry-run`.
Stow must be available. The preview does not install tools or move files.

## Configuration

Use the source files for the current package and version lists:

| Location | Contents |
| --- | --- |
| [Brewfile](bootstrap/Brewfile) | macOS applications, GNU Stow, and the font |
| [mise configuration](packages/mise/.config/mise/config.toml) | Command-line tools and version constraints |
| [mise lockfile](packages/mise/.config/mise/mise.lock) | Resolved tool versions |
| [packages/](packages/) | Tool configuration, with paths relative to `$HOME` |
| [bootstrap/](bootstrap/) | Installation scripts and pinned zsh plugin commits |

## Theme

The themes are `ergo-light` (default) and `te-calm`.
From the repository root, select a theme:

```sh
(cd theme && bb -m generate --theme te-calm)
```

Reload the tools to apply the colors.
See the [theme guide](theme/README.md) for previews, token edits, and regeneration.

## Guides

- [Setup and maintenance](docs/setup.md): SSH, backups, package links, and updates.
- [Zellij sessions](packages/zellij/.config/zellij/README.md): project sessions and navigation.
- [Helix REPL](docs/helix-repl.md): Clojure in Zellij and Django in Docker.
- [Writing conventions](docs/writing.md): documentation and comment style.
