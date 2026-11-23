#!/bin/sh
# Run a command in a full-size popup in whichever multiplexer hosts this Helix: Zellij or Rex.
# Rex has no floating panes, so it opens a new tab that closes when the command exits.
# --interactive reads ~/.zshrc, where mise puts gitu and lazygit on PATH.
if [ -n "${ZELLIJ:-}" ]; then
  exec zellij run --floating --close-on-exit -x 3% -y 3% --width 94% --height 94% -- "$@"
fi
exec rex run -s "$REX_SESSION" -c "$PWD" --interactive -- "$@"
