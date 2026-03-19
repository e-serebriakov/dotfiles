# Zellij (Experimental)

> tmux remains the primary setup. This is a parallel config for future experimentation.

## Install

```sh
brew install zellij
```

## Apply config via stow

```sh
cd ~/dotfiles/packages
stow zellij
```

## Start a session with the work layout

```sh
zellij --layout ~/.config/zellij/layouts/work.kdl
```

## Layout

- **Top 75%**: nvim (left 60%) | Claude Code (right 40%)
- **Bottom 25%**: tests (left) | logs (right)

## Per-service sessions

Copy the template layout and adapt the `cwd` and startup commands:

```sh
cp ~/.config/zellij/layouts/svc-template.kdl ~/.config/zellij/layouts/svc-myservice.kdl
# Edit cwd and commands inside the file, then:
zellij --layout ~/.config/zellij/layouts/svc-myservice.kdl
```

## Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+Space` | Enter Pane mode (prefix) |
| `Ctrl+Space` (in Pane mode) | Return to Normal |
| `h/j/k/l` (in Pane mode) | Navigate panes |
| `Ctrl+g` | Open lazygit floating pane |
