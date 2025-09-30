-- ~/.config/wezterm/wezterm.lua
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ---------- Window / font ----------
config.initial_cols = 120
config.initial_rows = 28
config.font_size = 14
config.window_decorations = "RESIZE"
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }

-- ---------- Theme (externalized) ----------
local theme = require("colors.paper_light")
config.colors = theme.colors

-- ---------- Tab bar toggles ----------
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false

-- ---------- Subtle dim on inactive panes ----------
config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.92 }

-- ---------- Truecolor hint ----------
config.set_environment_variables = { COLORTERM = "truecolor" }

-- ---------- SSH domains ----------
config.ssh_domains = {
  {
    name = "rbp",
    remote_address = "rbp",
    username = "minnijamil",
  },
}

return config
