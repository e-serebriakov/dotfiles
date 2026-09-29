# Zellij

## Setup

```sh
./bootstrap/install.sh  # from the dotfiles repo root
```

## Usage

Launch a project session (attaches if already running):

```sh
dev deltia
```

The `dev` function (in `.zshrc`) resolves project names via zoxide, `cd`s there,
and launches Zellij with the standard `work` layout. All panes inherit the project root as cwd.

Just `cd` into a project directory once so zoxide learns it.

Use `dev` for the current directory or `dev /path/to/project` for an explicit path.
Tab completion offers full project paths from zoxide.
Session names combine a shortened directory name with a checksum of its physical
path (at most 24 ASCII characters). Different queries or symlinks for the same
directory share a session; same-named directories get different checksums.
Sessions created with the old naming scheme remain available through
`zellij attach <old-name>`; `dev` starts using the new names immediately.

## Navigation

Zellij starts **locked**: every key goes to nvim/the shell except these, which work anywhere:

- `Alt+hjkl` — pane/tab navigation
- `Alt+f` — toggle floating pane, `Alt+n` — new pane

For anything else, press `Ctrl+g` to unlock, then pick a mode. After the action Zellij locks again:

- `Ctrl+g Ctrl+p` — pane mode (`m` for move mode), `Ctrl+g Ctrl+t` — tab mode, `Ctrl+g Ctrl+n` — resize mode
- `Ctrl+g Ctrl+s` — scroll/search, `Ctrl+g Ctrl+o` — session mode (`w` switch, `d` detach, `q` quit)
- `Ctrl+g` again (or `Esc` once inside a mode) — back to locked without doing anything
