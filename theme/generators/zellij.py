"""Zellij adapter: a small named-colour theme block."""

from theme.engine import GENERATED_BANNER, ROOT

OUTPUT = ROOT / "packages/zellij/.config/zellij/themes/ergo-light.kdl"


def render(sem):
    return f"""// {GENERATED_BANNER}
themes {{
    ergo-light {{
        fg      "{sem("text.primary")}"
        bg      "{sem("surface.base")}"
        black   "{sem("surface.tile")}"
        red     "{sem("status.error")}"
        green   "{sem("accent.string")}"
        yellow  "{sem("status.warning")}"
        blue    "{sem("status.info")}"
        magenta "{sem("terminal.ansi.magenta")}"
        cyan    "{sem("terminal.ansi.cyan")}"
        white   "{sem("text.secondary")}"
        orange  "{sem("accent.warm")}"
    }}
}}
"""
