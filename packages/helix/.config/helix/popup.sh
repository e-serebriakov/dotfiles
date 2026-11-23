#!/bin/sh
# Run a command in a full-size popup in whichever multiplexer hosts this Helix: Zellij or Rex.
# Both close the popup when the command exits.
if [ -n "${ZELLIJ:-}" ]; then
  exec zellij run --floating --close-on-exit -x 3% -y 3% --width 94% --height 94% -- "$@"
fi
# rex run can't float a block, so call the API. interactive reads ~/.zshrc, where mise puts gitu and lazygit on PATH.
jq -n --arg s "$REX_SESSION" --arg cwd "$PWD" '{
  session_id: $s, bounds: [0.03, 0.03, 0.94, 0.94], focus: true,
  layout: {block: {flavor: "com.superlogical.terminal.shell",
    options: {command: $ARGS.positional, cwd: $cwd, interactive: true}}}
}' --args -- "$@" | rex api call session.new_layer - >/dev/null
