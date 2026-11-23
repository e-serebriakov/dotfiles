# Rex

Rex is the terminal and the multiplexer. [`init.lua`](init.lua) holds the keys and the `dev` project action.
Run `rex config reload` after you change `init.lua`. Rex does not watch the file.

## Setup

Rex is in beta and has no Homebrew cask. Install Rex.app from the [Rex installation page](https://www.superlogical.com/rex/docs/installation).
Then run `./bootstrap/install.sh` from the repository root.

Set these values once in the Rex settings. Rex keeps them in the app, not in `init.lua`:

- Terminal > Typography: JetBrainsMono Nerd Font, size 13.
- Themes: import `~/.config/rex/themes/baked-light` and `baked-dark` for the light and dark slots. See the [theme guide](../../../../theme/README.md).
- Rex Server > Remote Control: turn it on. Without it, `dev` in the shell creates the session but cannot show it.

## Open a project

Press `Cmd+O` and select a project from zoxide.
Alternatively, run `dev` in a shell:

```sh
dev            # the current directory
dev ~/code/app # a specified directory
dev app        # a zoxide query
```

`dev` shows the project's session if it exists.
Otherwise, it creates a session with the name of the directory and two tabs:

- `work`: Helix (`editor`) above a shell (`REPL`) on the left, and a shell (`agent`) on the right.
- `feedback`: two shells, `logs` and `shell`.

Run `cd` to enter a project directory once. This adds the directory to zoxide.
Two directories with the same name share a session.

## Pane names

The editor keys find their target pane by its name in the current session:

- `Space t e` and `Space t l` in Helix, and `,E` in Neovim, send code to the `REPL` pane.
- `Space t a` in Helix sends a file reference to the `agent` pane.

`dev` gives the panes these names. Names ignore case.
To use another pane, rename it with Rename Pane in the command palette.
If no pane or more than one pane has the name, nothing is sent.
Helix then shows "Shell command failed: status 3", and Neovim shows the Rex error.

## Keys

Keys go to the program in the pane by default.

- `Alt+h`, `Alt+j`, `Alt+k`, `Alt+l`: focus the pane to the left, below, above, or to the right.
- `Alt+m`: zoom the focused pane.
- `Alt+f`: show or hide the floating panes of the tab. If the tab has no floating pane, open one.
- `Cmd+P`: go to a session, tab, or pane.
- `Shift+Cmd+P`: open the command palette.

Press `Ctrl+g` to enter the `unlocked` mode.
In this mode, press `n` to split the focused pane.
Press `Esc` or `Ctrl+g` to leave the mode.
