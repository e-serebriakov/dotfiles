#!/bin/sh
# Run a command in a floating Rex pane over the whole window. The pane closes when the command exits.
# rex run can't float a block, so call the API. interactive reads ~/.zshrc, where mise puts gitu and lazygit on PATH.
jq -n --arg s "$REX_SESSION" --arg cwd "$PWD" '{
  session_id: $s, bounds: [0.03, 0.03, 0.94, 0.94], focus: true,
  layout: {block: {flavor: "com.superlogical.terminal.shell",
    options: {command: $ARGS.positional, cwd: $cwd, interactive: true}}}
}' --args -- "$@" | rex api call session.new_layer - >/dev/null
