local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Window / font
config.initial_cols = 120
config.initial_rows = 28
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14
config.window_decorations = "RESIZE"
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }

config.color_scheme = "Ergo Light"

-- Behaviors (non-color)
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false

-- Make sure cursor colors aren’t overridden by reverse video
config.force_reverse_video_cursor = true

config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.92 }

-- Enable Kitty keyboard protocol so Ctrl+Alt+letter combos reach Zellij correctly
config.enable_kitty_keyboard = true

-- Send Alt as modifier, not as macOS special characters
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.set_environment_variables = { COLORTERM = "truecolor" }

return config
