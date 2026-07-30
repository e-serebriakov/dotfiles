#!/usr/bin/env python3
"""Ergo Light theme generator — CLI entry point.

Reads the tool-agnostic design tokens (theme/ergo-light.tokens.json) and writes
the per-tool theme files. The engine (theme/engine.py) resolves tokens; each
generator (theme/generators/) maps semantics onto one tool's keys; the tokens
file never mentions a tool.

Usage:
    theme/generate.py            # write all tool files + the committed preview.svg
    theme/generate.py --preview  # print the theme to the terminal, write nothing
"""

import json
import sys
from pathlib import Path

# Runnable two ways — `python3 theme/generate.py` (install.sh) and imported as
# `theme.generate` (tests). As a script, __package__ is empty and the repo root
# isn't on the path, so put it there before the package imports resolve.
if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from theme.engine import (  # noqa: E402  (import after the path bootstrap above)
    Contract,
    GENERATED_BANNER,
    PREVIEW,
    Theme,
    ThemeError,
    TOKENS,
    defined_tokens,
    references,
    write_if_changed,
)
from theme.generators import (  # noqa: E402
    ADAPTERS,
    _preview_rows,
    gen_preview,
    preview_ansi,
)


def build(theme, adapters=ADAPTERS):
    """Render every adapter to an in-memory {path: content} map. Pure — no I/O,
    so the whole generator is assertable without touching the filesystem."""
    return {path: render(theme) for path, render in adapters}


def check(tokens, adapters=ADAPTERS):
    """Cross-check a token tree against what the adapters actually consume, in
    both directions, in one pass. Pure — no I/O."""
    referenced = frozenset().union(*(references(fn) for _, fn in adapters))
    return Contract(defined_tokens(tokens), referenced)


def main():
    tokens = json.loads(TOKENS.read_text())
    contract = check(tokens)
    if contract.missing:  # a dangling reference would crash generation — stop first
        raise ThemeError(
            "token contract broken — adapters reference undefined tokens: "
            + ", ".join(sorted(contract.missing))
        )
    theme = Theme.from_tokens(tokens)  # reuse the parsed dict; no second read
    for path, content in build(theme).items():
        write_if_changed(path, content)
    write_if_changed(PREVIEW, gen_preview(theme))  # committed README image
    if contract.unused:  # rot, not breakage — warn locally, fail in the contract test
        print("warning: unused semantic tokens: " + ", ".join(sorted(contract.unused)))


if __name__ == "__main__":
    try:
        if "--preview" in sys.argv[1:]:  # print the theme to the terminal, write nothing
            sys.stdout.write(preview_ansi(Theme.from_file()))
        else:
            main()
    except ThemeError as e:  # SystemExit belongs only at the CLI edge
        raise SystemExit(str(e))
