#!/usr/bin/env python3
"""Ergo Light theme engine — the tool-agnostic core the generators build on.

Resolves the design tokens (theme/ergo-light.tokens.json) into a `Theme` a
generator can query with `sem('surface.base')`, and provides the tokens<->adapter
contract primitives. Knows nothing about any specific tool: the generators
(theme/generators/) map semantics onto each tool's keys; this module never does.

Stdlib only (no deps): a plain JSON parse of the tokens file; a single regex
detects the {alias} reference form. No external TOML/JSON-schema libs.
"""

import json
import re
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
TOKENS = Path(__file__).resolve().parent / "ergo-light.tokens.json"

# The one COMMITTED generated file (the rest are gitignored build artifacts): a
# README image has to be tracked to render on GitHub. Regenerated so it can
# never drift from the tokens.
PREVIEW = Path(__file__).resolve().parent / "preview.svg"

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


def write_if_changed(path, content):
    """Write only when content differs, so unchanged tokens don't bump mtimes
    (which would needlessly retrigger downstream file-watchers on every install)."""
    if path.exists() and path.read_text() == content:
        print(f"unchanged {path.relative_to(ROOT)}")
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content)
    print(f"wrote {path.relative_to(ROOT)}")


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
