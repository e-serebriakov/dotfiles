local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Window / font
config.initial_cols = 120
config.initial_rows = 28
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14
config.window_decorations = "RESIZE"
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }

config.color_scheme = "baked"

-- Tab bar
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false

-- Tabs show [01] title, [02] title, ...
-- For a Zellij title such as "backend-3059699869 | editor", show only "backend".
wezterm.on("format-tab-title", function(tab)
  local title = tab.tab_title ~= "" and tab.tab_title or tab.active_pane.title
  local session = title:match("^(%S+) | ")
  if session then
    title = session:gsub("%-%d+$", "")
  end
  return string.format(" [%02d] %s ", tab.tab_index + 1, title)
end)

-- Cmd+P opens a directory selector. The selected directory opens in a new tab with its Zellij session (dev).
-- zsh -ic loads .zshrc, which puts mise-installed zoxide on PATH and defines dev.
config.keys = {
  {
    key = "p",
    mods = "SUPER",
    action = wezterm.action_callback(function(window, pane)
      local ok, out = wezterm.run_child_process({ "/bin/zsh", "-ic", "zoxide query -l" })
      if not ok then
        return
      end
      local choices = {}
      for dir in out:gmatch("[^\n]+") do
        table.insert(choices, { id = dir, label = (dir:gsub("^" .. wezterm.home_dir, "~")) })
      end
      window:perform_action(
        wezterm.action.InputSelector({
          title = "Open project",
          fuzzy = true,
          choices = choices,
          action = wezterm.action_callback(function(win, p, id)
            if id then
              win:perform_action(
                wezterm.action.SpawnCommandInNewTab({ cwd = id, args = { "/bin/zsh", "-ic", "dev" } }),
                p
              )
            end
          end),
        }),
        pane
      )
    end),
  },
}

-- Use reverse video for the cursor.
config.force_reverse_video_cursor = true
-- Blink interval in ms for blinking cursor styles (zsh insert mode uses a blinking beam).
config.cursor_blink_rate = 600

config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.92 }

-- Use the Kitty keyboard protocol to send Ctrl+Alt+letter combinations to Zellij.
config.enable_kitty_keyboard = true

-- Send Alt as a modifier. Do not send macOS special characters.
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.set_environment_variables = { COLORTERM = "truecolor" }

return config
