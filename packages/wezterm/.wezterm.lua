-- text-first minimal — paper-light palette to mirror my Helix theme
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ---------- Window / font ----------
config.initial_cols = 120
config.initial_rows = 28
config.font_size = 14
config.window_decorations = "RESIZE"
config.window_padding = { left = 6, right = 6, top = 4, bottom = 4 }

-- IMPORTANT: preset schemes override custom colors, so leave this disabled:
-- config.color_scheme = "One Light (Gogh)"

-- ---------- Palette ----------
local paper         = "#FAFAF8"
local panel         = "#F3F3F1"
local divider       = "#DDDDDA"
local line          = "#EFEFEF"
local text          = "#121212"
local text_soft     = "#4A4F55"
local comment_fg    = "#6B7076"
local sel_secondary = "#E6E6E6"
local sel_primary   = "#D6DADF"
local link_fg       = "#3A6B90"

-- Muted ANSI (used by TUI/SSH apps that don’t emit truecolor)
local red     = "#B2473F"
local amber   = "#8A6A1F"
local green   = "#2F6B3A"
local blue    = "#3A6B90"
local magenta = "#7B4B86"
local cyan    = "#356E95"

-- ---------- Colors ----------
config.colors = {
  foreground = text,
  background = paper,

  cursor_bg = text,
  cursor_fg = paper,
  cursor_border = text,

  selection_bg = sel_primary,
  selection_fg = text,

  scrollbar_thumb = divider,
  split = divider,

  -- Copy-mode / quick-select (ColorSpec tables)
  copy_mode_active_highlight_bg   = { Color = paper },
  copy_mode_active_highlight_fg   = { AnsiColor = "Black" },
  copy_mode_inactive_highlight_bg = { Color = sel_secondary },
  copy_mode_inactive_highlight_fg = { AnsiColor = "Black" },

  quick_select_label_bg = { Color = blue },
  quick_select_label_fg = { Color = paper },
  quick_select_match_bg = { Color = sel_primary },
  quick_select_match_fg = { Color = text },

  -- Tab bar (keeps your structure, matches palette)
  tab_bar = {
    background = panel,

    active_tab = {
      bg_color = panel,
      fg_color = text,
      intensity = "Bold",
    },

    inactive_tab = {
      bg_color = panel,
      fg_color = comment_fg,
    },

    inactive_tab_hover = {
      bg_color = line,
      fg_color = text,
      italic = true,
    },

    new_tab = {
      bg_color = panel,
      fg_color = text_soft,
    },

    new_tab_hover = {
      bg_color = paper,
      fg_color = link_fg, -- calm blue on hover
      italic = true,
    },
  },

  -- ANSI palettes (for 16/256-color apps)
  ansi = {
    "#101010", -- black
    red,       -- red
    green,     -- green
    amber,     -- yellow
    blue,      -- blue
    magenta,   -- magenta
    cyan,      -- cyan
    "#D0D0CC", -- white (soft)
  },
  brights = {
    "#3a3a3a", -- bright black
    "#C35C52", -- bright red
    "#3A7D47", -- bright green
    "#9D7C2A", -- bright yellow
    "#467AA4", -- bright blue
    "#8D5E92", -- bright magenta
    "#3F7FA3", -- bright cyan
    "#F0F0EB", -- bright white
  },
}

-- ---------- Tab bar toggles (yours) ----------
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false

-- ---------- Subtle dim on inactive panes ----------
config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.92 }

-- ---------- (Nice to have) advertise truecolor to local processes ----------
config.set_environment_variables = { COLORTERM = "truecolor" }

return config

