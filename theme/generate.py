#!/usr/bin/env python3
"""Ergo Light theme generator.

Reads the tool-agnostic design tokens (theme/ergo-light.tokens.json) and emits
the per-tool theme files. Each tool has an *adapter* below that maps semantic
tokens -> that tool's own keys; the tokens file never mentions a tool.

Usage:
    theme/generate.py            # write all tool files

Stdlib only (no deps): a plain JSON parse of the tokens file; a single regex
detects the {alias} reference form. No external TOML/JSON-schema libs.
"""

import json
import re
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOKENS = Path(__file__).resolve().parent / "ergo-light.tokens.json"

WEZTERM = ROOT / "packages/wezterm/.config/wezterm/colors/ergo_light.toml"
ZELLIJ = ROOT / "packages/zellij/.config/zellij/themes/ergo-light.kdl"
NVIM = ROOT / "packages/nvim/.config/nvim/lua/colorschemes/ergo_light_palette.lua"
DELTA = ROOT / "packages/git/.config/delta/ergo-light.gitconfig"

GENERATED_BANNER = "GENERATED from theme/ergo-light.tokens.json — do not edit by hand."


class ThemeError(Exception):
    """A token-graph or contract problem the user must fix. Raised by the engine;
    converted to a process exit only at the CLI boundary."""


# --- token graph -----------------------------------------------------------
def _flatten(node, prefix, out):
    """Collect every {path: raw_value_or_alias} leaf (a leaf has a $value)."""
    if isinstance(node, dict):
        if "$value" in node:
            out[prefix] = node["$value"]
            return
        for k, v in node.items():
            if k.startswith("$"):
                continue
            _flatten(v, f"{prefix}.{k}" if prefix else k, out)


ALIAS = re.compile(r"^\{(.+)\}$")


def _resolve(path, raw, raw_map, cache, stack=()):
    """Follow {alias} chains down to a concrete hex, memoized."""
    if path in cache:
        return cache[path]
    if path in stack:
        cycle = " -> ".join((*stack, path))
        raise ThemeError(f"token alias cycle: {cycle}")
    m = ALIAS.match(raw.strip())
    if m:
        target = m.group(1)
        if target not in raw_map:
            raise ThemeError(f"{path}: alias -> unknown token '{target}'")
        val = _resolve(target, raw_map[target], raw_map, cache, (*stack, path))
    else:
        val = raw
    cache[path] = val
    return val


class Theme:
    """A resolved semantic palette. Calling it looks up one semantic token's hex
    (`theme('surface.base')`); `.many(...)` returns a list. Hides flattening,
    alias resolution, cycle detection, and the `semantic.` prefix from adapters."""

    def __init__(self, resolved):
        self._res = resolved  # fully-qualified path -> hex (primitives incl., unused)

    def __call__(self, path):
        try:
            return self._res[f"semantic.{path}"]
        except KeyError:
            raise ThemeError(f"adapter references unknown semantic token '{path}'")

    def many(self, *paths):
        return [self(p) for p in paths]

    @classmethod
    def from_tokens(cls, tokens):
        """Build from an in-memory token tree (parsed JSON). Runs the full
        flatten + alias-resolve eagerly, so cycles/unknown aliases fail here."""
        raw_map = {}
        _flatten(tokens, "", raw_map)
        cache = {}
        return cls({p: _resolve(p, r, raw_map, cache) for p, r in raw_map.items()})

    @classmethod
    def from_file(cls, path=TOKENS):
        """The only filesystem read. `path` defaults to the tokens file."""
        return cls.from_tokens(json.loads(path.read_text()))


# --- adapters --------------------------------------------------------------
def gen_nvim(sem):
    # Keys must match the colorscheme's palette table.
    m = {
        "paper": "surface.base",
        "panel": "surface.raised",
        "line_primary": "selection.match",
        "line": "surface.cursorline",
        "line_column": "surface.column",
        "ruler_bg": "surface.ruler",
        "divider": "border.default",
        "code_bg": "surface.code",
        "text": "text.primary",
        "text_soft": "text.secondary",
        "comment_fg": "comment.fg",
        "comment_bg": "comment.bg",
        "comment_high_bg": "comment.high",
        "doc_fg": "doc.fg",
        "doc_bg": "doc.bg",
        "doc_quote_bg": "doc.quote",
        "doc_heading": "doc.heading",
        "link_fg": "accent.link",
        "string_fg": "accent.string",
        "const_fg": "accent.constant",
        "function_fg": "accent.function",
        "match_bg": "selection.match",
        "cursor_primary": "cursor.primary",
        "cursor_secondary": "cursor.secondary",
        "sel_secondary": "selection.secondary",
        "sel_primary": "selection.primary",
        "search_soft": "search.soft",
        "search_mid": "search.active",
        "err_fg": "status.error",
        "alert_fg": "alert.fg",
        "warn_fg": "status.warning",
        "info_fg": "status.info",
        "hint_fg": "status.hint",
        "diff_add_bg": "diff.add",
        "diff_change_bg": "diff.change",
        "diff_del_bg": "diff.delete",
        "diff_change_text_bg": "diff.changeText",
        "diff_conflict_bg": "diff.conflict",
        "popup_bg": "surface.popup",
        "popup_header_bg": "surface.popupHeader",
    }
    lines = [f"-- {GENERATED_BANNER}", "return {"]
    for k, tok in m.items():
        lines.append(f"  {k} = '{sem(tok)}',")
    lines.append("}")
    return "\n".join(lines) + "\n"


def gen_wezterm(sem):
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


def gen_zellij(sem):
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


def gen_delta(sem):
    # syntax-theme = ansi routes diff *foreground* highlighting through the
    # terminal's own ANSI palette (themed from these same tokens), so diffs use
    # one calm palette instead of a foreign bat theme fighting the diff tints.
    return f"""; {GENERATED_BANNER}
; Color styles only; behavioural delta settings live in the committed .gitconfig.
[delta]
    syntax-theme = ansi
    plus-style = "syntax {sem("diff.add")}"
    plus-emph-style = "syntax {sem("diff.addText")}"
    minus-style = "syntax {sem("diff.delete")}"
    minus-emph-style = "syntax {sem("diff.deleteText")}"
    hunk-header-style = "{sem("text.secondary")}"
    hunk-header-decoration-style = "{sem("border.default")} ul"
    file-style = "{sem("text.primary")} bold"
    file-decoration-style = "{sem("border.default")} ul"
    line-numbers-minus-style = "{sem("status.error")}"
    line-numbers-plus-style = "{sem("status.success")}"
    line-numbers-zero-style = "{sem("text.muted")}"
"""


def write_if_changed(path, content):
    """Write only when content differs, so unchanged tokens don't bump mtimes
    (which would needlessly retrigger downstream file-watchers on every install)."""
    if path.exists() and path.read_text() == content:
        print(f"unchanged {path.relative_to(ROOT)}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    print(f"wrote {path.relative_to(ROOT)}")


# (output path, adapter). Add a tool by appending one row — not by editing main().
ADAPTERS = [
    (WEZTERM, gen_wezterm),
    (ZELLIJ, gen_zellij),
    (NVIM, gen_nvim),
    (DELTA, gen_delta),
]


def build(theme):
    """Render every adapter to an in-memory {path: content} map. Pure — no I/O,
    so the whole generator is assertable without touching the filesystem."""
    return {path: render(theme) for path, render in ADAPTERS}


# --- token <-> adapter contract --------------------------------------------
@dataclass(frozen=True)
class Contract:
    """The tokens<->adapters agreement as two sets of semantic paths.
    `missing` = referenced by an adapter but absent from the JSON (a dangling
    sem() — a correctness break); `unused` = defined in the JSON but consumed by
    no adapter (silent rot)."""

    defined: frozenset
    referenced: frozenset

    @property
    def missing(self):
        return self.referenced - self.defined

    @property
    def unused(self):
        return self.defined - self.referenced

    @property
    def ok(self):
        return not (self.missing or self.unused)


def defined_tokens(tokens):
    """Semantic leaf paths of a token tree, `semantic.` prefix stripped — the
    vocabulary adapters address through `sem(...)`. Primitives are excluded by
    construction, mirroring the fact that adapters can only reach semantics."""
    flat = {}
    _flatten(tokens, "", flat)
    n = len("semantic.")
    return frozenset(p[n:] for p in flat if p.startswith("semantic."))


class _Probe:
    """A Theme-shaped stand-in that records which tokens an adapter asks for.
    Total — accepts any path and never raises — so a single sweep captures the
    FULL reference set, including references to *undefined* tokens that a real
    Theme would SystemExit on. Assumes adapters only interpolate the returned
    value, never branch on it (true while adapters are branch-free f-strings)."""

    def __init__(self):
        self.seen = set()

    def __call__(self, path):
        self.seen.add(path)
        return "#000000"

    def many(self, *paths):
        return [self(p) for p in paths]


def references(adapter):
    """Every semantic path one adapter requests. Pure in `adapter`: runs it once
    against a recording probe and returns the observed set."""
    probe = _Probe()
    adapter(probe)
    return frozenset(probe.seen)


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
    if contract.unused:  # rot, not breakage — warn locally, fail in the contract test
        print("warning: unused semantic tokens: " + ", ".join(sorted(contract.unused)))


if __name__ == "__main__":
    try:
        main()
    except ThemeError as e:  # SystemExit belongs only at the CLI edge
        raise SystemExit(str(e))
