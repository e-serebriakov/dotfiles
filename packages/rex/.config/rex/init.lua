-- Migrated from zellij (~/.config/zellij/config.kdl). zellij starts locked, so its
-- locked mode is Rex with no mode active, and its normal mode is the Rex mode "unlocked".

rex.action{
  name  = "then_normal",
  title = "Run an action and return to normal mode",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, args)
    rex.client.queue(args.action, args.args or {})
    rex.client.queue("client.mode.exit_all")
  end,
}

-- zellij locked mode
rex.bind("alt+h", "pane.focus", { direction = "left" })
rex.bind("alt+l", "pane.focus", { direction = "right" })
rex.bind("alt+j", "pane.focus", { direction = "down" })
rex.bind("alt+k", "pane.focus", { direction = "up" })
rex.bind("alt+m", "pane.zoom")

-- zellij normal mode, entered and left with Ctrl+g (zellij's default key)
rex.mode("unlocked", { exclusive = true })
rex.bind("ctrl+g", "client.mode.enter", { name = "unlocked" })
rex.bind("unlocked/ctrl+g", "client.mode.exit")
rex.bind("unlocked/esc", "client.mode.exit")
rex.bind("unlocked/n", "then_normal", { action = "pane.split.auto" })
