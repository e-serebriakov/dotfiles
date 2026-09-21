# Zellij

## Setup

```sh
brew install zellij
cd ~/dotfiles/packages && stow zellij
```

## Usage

Launch a project session (attaches if already running):

```sh
dev deltia
```

The `dev` function (in `.zshrc`) resolves project names via zoxide, `cd`s there,
and launches Zellij with the standard `work` layout. All panes inherit the project root as cwd.

Just `cd` into a project directory once so zoxide learns it.

## Navigation

- `Ctrl+hjkl` — seamless Neovim ↔ Zellij pane navigation (via zellij-nav.nvim + autolock)
- `Alt+hjkl` — pane/tab navigation (works in all modes)
- `Ctrl+p` — pane mode, `Ctrl+t` — tab mode, `Ctrl+n` — resize mode
- `Ctrl+p m` — move mode (move panes around)
- `Ctrl+g` — lock
