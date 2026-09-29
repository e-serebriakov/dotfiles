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

Zellij starts **locked**. Keys go to Neovim or the shell, except these shortcuts, which work in all modes:

- `Alt+hjkl` — pane/tab navigation
- `Alt+f` — toggle floating pane, `Alt+n` — new pane

For other actions, press `Ctrl+g` to unlock, then select a mode.
Most actions return to locked mode. Navigation and resizing can remain in their mode.

- `Ctrl+g Ctrl+p` — pane mode (`m` for move mode), `Ctrl+g Ctrl+t` — tab mode, `Ctrl+g Ctrl+n` — resize mode
- `Ctrl+g Ctrl+s` — scroll/search, `Ctrl+g Ctrl+o` — session mode (`w` switch, `d` detach, `q` quit)
- `Ctrl+g` again — return to locked mode. `Esc` also exits most modes; search and rename modes have separate behavior.
