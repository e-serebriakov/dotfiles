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

- `Alt+hjkl` — pane/tab navigation (works in all modes)
- `Ctrl+p` — pane mode, `Ctrl+t` — tab mode, `Ctrl+n` — resize mode
- `Ctrl+p m` — move mode (move panes around)
- `Ctrl+g` — toggle lock (use it to pass Zellij's other shortcuts through to the editor)

Locking is manual. Restart existing sessions to unload the former autolock plugin.
