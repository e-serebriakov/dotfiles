-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Use the config_builder
local config = wezterm.config_builder()

-- General window setup
config.initial_cols = 120
config.initial_rows = 28
config.font_size = 14

config.color_scheme = "One Light (Gogh)"

-- Tab bar styling
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false

config.colors = {
	foreground = "#383a42",
	background = "#eeeeee",

	tab_bar = {
		background = "#eeeeee", -- общий фон tabbar

		active_tab = {
			bg_color = "#eeeeee",
			fg_color = "#444444",
			intensity = "Bold",
		},

		inactive_tab = {
			bg_color = "#eeeeee",
			fg_color = "#888888",
		},

		inactive_tab_hover = {
			bg_color = "#dddddd",
			fg_color = "#444444",
			italic = true,
		},

		new_tab = {
			bg_color = "#eeeeee",
			fg_color = "#444444",
		},

		new_tab_hover = {
			bg_color = "#ffffff",
			fg_color = "#268bd2", -- синий при наведении
			italic = true,
		},
	},
}

-- Return the final config
return config
