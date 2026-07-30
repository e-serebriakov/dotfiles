"""WezTerm adapter: the terminal palette (incl. the 16 ANSI slots) + tab bar."""

from theme.engine import GENERATED_BANNER, ROOT

OUTPUT = ROOT / "packages/wezterm/.config/wezterm/colors/ergo_light.toml"


def render(sem):
    ansi = sem.many(
        "terminal.ansi.black",
        "terminal.ansi.red",
        "terminal.ansi.green",
        "terminal.ansi.yellow",
        "terminal.ansi.blue",
        "terminal.ansi.magenta",
        "terminal.ansi.cyan",
        "terminal.ansi.white",
    )
    bright = sem.many(
        "terminal.bright.black",
        "terminal.bright.red",
        "terminal.bright.green",
        "terminal.bright.yellow",
        "terminal.bright.blue",
        "terminal.bright.magenta",
        "terminal.bright.cyan",
        "terminal.bright.white",
    )

    def tab(bg, fg, *, italic="false", intensity="Normal"):
        return (
            f'bg_color = "{bg}"\nfg_color = "{fg}"\nintensity = "{intensity}"\n'
            f'italic = {italic}\nunderline = "None"\nstrikethrough = false'
        )

    return f"""# {GENERATED_BANNER}
[metadata]
name = "Ergo Light"
wezterm_version = "*"

[colors]
foreground = "{sem("text.primary")}"
background = "{sem("surface.base")}"

cursor_bg = "{sem("cursor.primary")}"
cursor_fg = "{sem("surface.base")}"
cursor_border = "{sem("cursor.primary")}"

selection_bg = "{sem("selection.primary")}"
selection_fg = "{sem("text.primary")}"

scrollbar_thumb = "{sem("border.default")}"
split = "{sem("border.default")}"

ansi = [
  "{ansi[0]}", "{ansi[1]}", "{ansi[2]}", "{ansi[3]}",
  "{ansi[4]}", "{ansi[5]}", "{ansi[6]}", "{ansi[7]}",
]
brights = [
  "{bright[0]}", "{bright[1]}", "{bright[2]}", "{bright[3]}",
  "{bright[4]}", "{bright[5]}", "{bright[6]}", "{bright[7]}",
]

[colors.tab_bar]
background = "{sem("surface.raised")}"
inactive_tab_edge = "{sem("border.default")}"

[colors.tab_bar.active_tab]
{tab(sem("surface.raised"), sem("text.primary"), intensity="Bold")}

[colors.tab_bar.inactive_tab]
{tab(sem("surface.raised"), sem("comment.fg"))}

[colors.tab_bar.inactive_tab_hover]
{tab(sem("surface.cursorline"), sem("text.primary"), italic="true")}

[colors.tab_bar.new_tab]
{tab(sem("surface.raised"), sem("text.secondary"))}

[colors.tab_bar.new_tab_hover]
{tab(sem("surface.base"), sem("status.info"), italic="true")}
"""
