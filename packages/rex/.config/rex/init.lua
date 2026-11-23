-- Keys go to the program in the pane by default. Ctrl+g enters the "unlocked" mode for pane commands.
-- Run `rex config reload` after you change this file.

local shell = "com.superlogical.terminal.shell"

local function term(label, dir, input)
  return { block = { flavor = shell, label = label, options = { cwd = dir, initial_input = input } } }
end

local function split(direction, ratio, before, after)
  return { split = { direction = direction, ratio = ratio, before = before, after = after } }
end

-- The server's PATH lacks the mise shims. zsh -ic reads ~/.zshrc, which puts zoxide on PATH.
local function pick_project()
  local r, err = rex.exec({ "/bin/zsh", "-ic", "zoxide query -l" })
  if r == nil then error(err, 0) end
  if not r.ok then error("zoxide query failed: " .. r.stderr, 0) end
  local home, items = os.getenv("HOME"), {}
  for dir in r.stdout:gmatch("[^\n]+") do
    local short = dir:sub(1, #home) == home and "~" .. dir:sub(#home + 1) or dir
    items[#items + 1] = { id = dir, title = dir:match("[^/]+$"), subtitle = short, icon = "folder" }
  end
  return rex.ui.pick{ title = "Open project", placeholder = "Filter projects", items = items }
end

-- Open the project's session, or create it with the work and feedback tabs. dev in .zshrc calls this action.
-- ponytail: the session label is the directory name, so two projects with the same name share a session.
-- Add the parent directory to the label if that happens.
rex.action{
  name        = "dev",
  title       = "Open Project…",
  description = "Open the project's session, or create it with the work and feedback tabs.",
  args        = { dir = "string?" },
  run         = function(ctx, args)
    local dir = args.dir or pick_project()
    if dir == nil then return end
    local label = dir:match("([^/]+)/*$")

    local list, err = rex.call("session.list")
    if err ~= nil then error(err, 0) end
    local id
    for _, s in ipairs(list.sessions or {}) do
      if s.label == label then id = s.session_id end
    end

    if id == nil then
      local created
      created, err = rex.call("session.create", {
        label = label,
        initial_windows = {
          { window_label = "work", layout = split("horizontal", 0.5,
              split("vertical", 0.75, term("editor", dir, "hx .\n"), term("REPL", dir)),
              term("agent", dir)) },
        },
      })
      if err ~= nil then error(err, 0) end
      id = created.session_id
      -- Add feedback after work. The last initial window would become the active one.
      -- A window method fails unless the caller is attached to the window's session.
      _, err = rex.call("session.attach", { session_id = id })
      if err ~= nil then error(err, 0) end
      _, err = rex.session.new_window{ session_id = id, window_label = "feedback", focus = false,
        layout = split("horizontal", 0.5, term("logs", dir), term("shell", dir)) }
      if err ~= nil then error(err, 0) end
    end

    -- From the CLI, no app asked, so dev in .zshrc selects the session itself.
    if ctx.origin == "key" or ctx.origin == "palette" then
      rex.client.queue("session.select", { session_id = id })
    end
    return { session_id = id }
  end,
}

-- Show or hide the floating panes of the current tab, or open one if the tab has none.
rex.action{
  name  = "toggle_floating",
  title = "Toggle Floating Panes",
  run   = function(ctx)
    local view, err = rex.session.view{}
    if err ~= nil then error(err, 0) end
    local floating, shown = {}, false
    for _, w in ipairs(view.windows) do
      if w.window_id == view.active_window_id then
        for i = 2, #w.layers do -- layers[1] is the tiled layout
          floating[#floating + 1] = w.layers[i]
          shown = shown or w.layers[i].state ~= "minimized"
        end
      end
    end
    if #floating == 0 then
      rex.client.queue("pane.new_floating")
      return
    end
    for i, layer in ipairs(floating) do
      rex.session.set_layer_state{
        layer_id = layer.layer_id,
        state    = shown and "minimized" or "normal",
        focus    = not shown and i == #floating,
      }
    end
  end,
}

rex.action{
  name  = "then_normal",
  title = "Run an action and return to normal mode",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, args)
    rex.client.queue(args.action, args.args or {})
    rex.client.queue("client.mode.exit_all")
  end,
}

-- Cmd+P is Go to Anything in Rex, so the project picker uses Cmd+O.
rex.bind("cmd+o", "dev")

rex.bind("alt+h", "pane.focus", { direction = "left" })
rex.bind("alt+l", "pane.focus", { direction = "right" })
rex.bind("alt+j", "pane.focus", { direction = "down" })
rex.bind("alt+k", "pane.focus", { direction = "up" })
rex.bind("alt+m", "pane.zoom")
rex.bind("alt+f", "toggle_floating")

rex.mode("unlocked", { exclusive = true })
rex.bind("ctrl+g", "client.mode.enter", { name = "unlocked" })
rex.bind("unlocked/ctrl+g", "client.mode.exit")
rex.bind("unlocked/esc", "client.mode.exit")
rex.bind("unlocked/n", "then_normal", { action = "pane.split.auto" })
