# Setup and maintenance

Run repository commands from its root directory unless a step specifies a different location.
See the [README](../README.md#install) for installation commands.

## SSH access

Before you clone through SSH, make sure that GitHub accepts your authentication key.
Copy private keys through a secure channel. This repository does not contain them.
The shared configuration uses `~/.ssh/auth` for authentication and `~/.ssh/sign` for signing.

If your GitHub key is `~/.ssh/auth`, add this host configuration to `~/.ssh/config` before the clone:

```sshconfig
Host github.com
  User git
  IdentityFile ~/.ssh/auth
```

Use the path of your registered key if it is different.
Keep private hosts and tool-managed sections (OrbStack, DevPod) in `~/.ssh/config`.
Git does not track this file.

After setup creates the symbolic links, include the shared defaults in `~/.ssh/config`:

```sshconfig
Host *
  Include ~/.ssh/config.d/*.conf
```

The position of `Include` determines which `Host` or `Match` block applies to it.
Put the shared include in global scope or in a `Host *` block.
The [defaults](../packages/ssh/.ssh/config.d/defaults.conf) configure identity files, `AddKeysToAgent`, and `UseKeychain`.
`IgnoreUnknown` lets Linux ignore `UseKeychain`.

On macOS, setup loads the configured auth and sign keys into Keychain if their files exist.
To load them manually:

```sh
ssh-add --apple-use-keychain ~/.ssh/auth ~/.ssh/sign
```

On Linux, `.zshrc` starts a shared agent at `~/.ssh/agent.sock` when no agent socket is available.
`AddKeysToAgent` adds a key when a command first uses it.
The passphrase prompt appears with that command, not at shell startup.
Setup also creates `~/.ssh/allowed_signers` if `~/.ssh/sign.pub` exists and the allowed-signers file is absent.

## Setup behavior

[install.sh](../bootstrap/install.sh) installs platform packages through Homebrew or apt, then installs mise.
Ubuntu setup also sets zsh as the login shell.
The script restores the specified zsh plugin commits in `~/.local/share/zsh`.
Local plugin changes stop setup before the script replaces them.

Setup installs the locked Babashka version before theme generation.
It then creates symbolic links through Stow and installs the remaining mise tools with `--locked`.
You can run setup again after you correct an error.
`DOTFILES_CONTEXT` only changes the context label in the setup log. It does not select a different configuration.

### Backups

Before Stow creates links, setup moves conflicting files and symbolic links to `~/.dotfiles-backup/<timestamp>/`.
It keeps their relative paths and links that point to the package files.
It also keeps uncommitted changes in `packages/`.

Setup skips a backup if an ancestor link points to a directory outside `packages/`.
Stow can then report an unresolved conflict.
Examine the paths before you change them.

### Recovery

If theme generation fails, setup continues to the Stow step.
This does not guarantee a usable theme for each tool.
Correct the generation error. Then regenerate the theme:

```sh
(cd theme && bb -m generate)
```

If mise reports a tool installation error, correct it. Then retry:

```sh
mise install --locked
```

If mise itself is missing, install it. Then run setup again.

## Manage package links

Each directory in `packages/` matches the layout of `$HOME`.
For example, Stow links `packages/nvim/.config/nvim/` to `~/.config/nvim/`.

```sh
# Create or update the symbolic links for one package.
stow -R -d packages -t "$HOME" nvim

# Remove the symbolic links for one package.
stow -D -d packages -t "$HOME" nvim
```

To add a configuration:

1. Create `packages/<name>/` with the same directory layout as `$HOME`.
2. Move the configuration file into that directory.
3. Run `./bootstrap/install.sh` again.

## Update tools

Setup uses the committed mise lockfile and zsh plugin revisions.
To update a mise tool, use these commands:

```sh
MISE_GLOBAL_CONFIG_FILE="$PWD/packages/mise/.config/mise/config.toml" mise lock --global --bump babashka
git diff -- packages/mise/.config/mise/mise.lock
./bootstrap/install.sh
```

To update a different tool, replace `babashka` with its name.
To update all tools, do not specify a tool name.
The updates stay in the configured version ranges.
Do the tool tests. Review the lockfile. Commit the lockfile.

The theme generator pins its own Babashka version in `theme/mise.toml`.
To update it, change the version in that file. Then update the lockfile:

```sh
(cd theme && mise lock)
git diff -- theme/mise.lock
```

To update a zsh plugin:

1. Find its upstream commit. For example:

   ```sh
   git ls-remote https://github.com/Aloxaf/fzf-tab HEAD
   ```

2. Replace its full commit ID in the `PLUGINS` block in `bootstrap/install.sh`.
3. Run setup again.
4. Do the plugin tests in a new shell before you commit the change.

Homebrew applications and Ubuntu packages do not use version locks.
Setup skips the usual Homebrew upgrades, but dependency installation can make upgrades necessary.
To upgrade the Brewfile packages:

```sh
brew bundle --upgrade --file bootstrap/Brewfile
```
