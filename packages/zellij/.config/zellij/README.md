# Zellij

## Setup

```sh
./bootstrap/install.sh  # Run from the repository root.
```

## Usage

Start a project session or attach to its existing session:

```sh
dev deltia
```

The `dev` function in `.zshrc` finds projects with zoxide and starts new sessions with the `work` layout.
All panes start in the project directory.
Run `cd` to enter the project directory once. This adds it to zoxide.

Use `dev` for the current directory or `dev /path/to/project` for a specific path.
Tab completion lists project paths from zoxide.

Session names contain a shortened directory name and a checksum of the physical path, with a limit of 24 ASCII characters.
Queries and symbolic links to the same directory share a session.
The checksum distinguishes directories with the same name.
Use `zellij attach <old-name>` for sessions created before this naming scheme. `dev` uses the new names.

## Navigation

Zellij uses its default keybindings but starts **locked**. Keys go to Neovim or the shell, except these shortcuts, which work in all modes:

- `Alt+hjkl` — pane/tab navigation
- `Alt+f` — toggle floating pane, `Alt+n` — new pane
- `Alt+/` — show keybindings for the current mode (compact-bar tooltip)

Press `Ctrl+g` to unlock into normal mode, then use Zellij's default keys (`Ctrl+p` pane, `Ctrl+t` tab, `Ctrl+o` session, `Ctrl+q` quit, ...).
Actions return to normal mode, not locked. Press `Esc` or `Ctrl+g` to lock again, or Neovim and the shell won't receive those Ctrl keys.
