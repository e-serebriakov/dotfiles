"""The per-tool generators, as one array the engine drives.

Add a tool: drop a `<tool>.py` here exposing `OUTPUT` (Path) and `render(sem)`,
then add one row to ADAPTERS below. Nothing in the engine or CLI changes.

The previews (preview.py) are re-exported but intentionally NOT in ADAPTERS —
see that module for why.
"""

from theme.generators import delta, helix, nvim, wezterm, zellij
from theme.generators.preview import _preview_rows, gen_preview, preview_ansi

# (output path, render). Order = generation/report order.
ADAPTERS = [
    (wezterm.OUTPUT, wezterm.render),
    (zellij.OUTPUT, zellij.render),
    (nvim.OUTPUT, nvim.render),
    (delta.OUTPUT, delta.render),
    (helix.OUTPUT, helix.render),
]

__all__ = ["ADAPTERS", "gen_preview", "preview_ansi", "_preview_rows"]
