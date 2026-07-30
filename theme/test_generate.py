#!/usr/bin/env python3
"""Boundary tests for the theme generator. Stdlib only: python3 -m unittest.

Run from the repo root:  python3 -m unittest theme.test_generate
"""

import json
import unittest

from theme import generate
from theme.generate import Theme, ThemeError, build, check


class TestResolution(unittest.TestCase):
    def test_single_and_chained_alias(self):
        t = Theme.from_tokens(
            {
                "primitive": {"gray": {"50": {"$value": "#fafafa"}}},
                "semantic": {
                    "surface": {
                        "raised": {"$value": "{primitive.gray.50}"},
                        "base": {
                            "$value": "{semantic.surface.raised}"
                        },  # alias -> alias
                    }
                },
            }
        )
        self.assertEqual(t("surface.raised"), "#fafafa")
        self.assertEqual(t("surface.base"), "#fafafa")

    def test_cycle_is_fatal(self):
        with self.assertRaisesRegex(ThemeError, "alias cycle"):
            Theme.from_tokens(
                {
                    "semantic": {
                        "a": {"$value": "{semantic.b}"},
                        "b": {"$value": "{semantic.a}"},
                    }
                }
            )

    def test_unknown_alias_is_fatal(self):
        with self.assertRaisesRegex(ThemeError, "unknown token"):
            Theme.from_tokens({"semantic": {"a": {"$value": "{primitive.nope}"}}})


class TestAccessor(unittest.TestCase):
    def setUp(self):
        # constructed from a pre-resolved dict — no file, no I/O
        self.t = Theme(
            {
                "semantic.surface.base": "#EEEEEE",
                "semantic.text.primary": "#353535",
            }
        )

    def test_call_and_many_preserve_order(self):
        self.assertEqual(self.t("surface.base"), "#EEEEEE")
        self.assertEqual(
            self.t.many("text.primary", "surface.base"), ["#353535", "#EEEEEE"]
        )

    def test_missing_token_is_fatal(self):
        with self.assertRaisesRegex(ThemeError, "unknown semantic token"):
            self.t("surface.nope")


class TestGoldenOutput(unittest.TestCase):
    """Regression guard: build() must reproduce the committed on-disk artifacts
    byte-for-byte, proving the refactor changed no generated output."""

    def test_build_matches_disk(self):
        outputs = build(Theme.from_file())
        self.assertEqual(len(outputs), len(generate.ADAPTERS))
        for path, content in outputs.items():
            with self.subTest(path=path.name):
                self.assertTrue(
                    path.exists(), f"{path} not generated yet — run generate.py"
                )
                self.assertEqual(path.read_text(), content)
                self.assertIn(generate.GENERATED_BANNER, content)

    def test_preview_matches_disk(self):
        """The committed README image is the one generated artifact that is
        tracked (not gitignored + regenerated on install), so a stale copy would
        ship to GitHub. Guard it against token drift like the adapter outputs."""
        content = generate.gen_preview(Theme.from_file())
        self.assertTrue(
            generate.PREVIEW.exists(),
            f"{generate.PREVIEW} not generated yet — run generate.py",
        )
        self.assertEqual(generate.PREVIEW.read_text(), content)
        self.assertIn(generate.GENERATED_BANNER, content)

    def test_preview_ansi_emits_every_row_colour(self):
        """The terminal preview must render the whole shared palette, not a
        subset — proving preview_ansi consumes the same _preview_rows the SVG
        does. Every hex named in a row appears as a truecolor (`2;r;g;b`) run."""
        theme = Theme.from_file()
        ansi = generate.preview_ansi(theme)
        self.assertTrue(ansi.startswith("\x1b["), "expected an opening SGR escape")
        _, _, _, rows = generate._preview_rows(theme)
        hexes = set()
        for _gutter, gcol, band, segs, _gap in rows:
            hexes.update(c for c in (gcol, band) if c)
            for _text, fg, opts in segs:
                hexes.update(c for c in (fg, opts.get("hl")) if c)
        for hx in hexes:
            h = hx.lstrip("#")
            triple = f"2;{int(h[0:2], 16)};{int(h[2:4], 16)};{int(h[4:6], 16)}"
            self.assertIn(triple, ansi, f"{hx} missing from ANSI preview")


class TestContract(unittest.TestCase):
    """Boundary tests for the tokens<->adapters contract. `check` takes plain
    data (a token dict + adapters) and returns plain data, so every case is a
    dict literal and a `lambda sem: ...` — no disk, no real adapters."""

    def test_repo_contract_holds(self):
        # the real tokens file and real adapters must agree in both directions
        tokens = json.loads(generate.TOKENS.read_text())
        contract = check(tokens)
        self.assertEqual(contract.missing, frozenset())  # no dangling sem()
        self.assertEqual(contract.unused, frozenset())  # no rotting token
        self.assertTrue(contract.ok)

    def test_missing_is_referenced_but_undefined(self):
        tokens = {"semantic": {"surface": {"base": {"$value": "#fff"}}}}
        adapter = lambda sem: sem("surface.base") + sem("surface.nope")
        contract = check(tokens, [(None, adapter)])
        self.assertEqual(contract.missing, {"surface.nope"})
        self.assertEqual(contract.unused, frozenset())
        self.assertFalse(contract.ok)

    def test_unused_is_defined_but_unconsumed(self):
        tokens = {"semantic": {"a": {"$value": "#1"}, "b": {"$value": "#2"}}}
        contract = check(tokens, [(None, lambda sem: sem("a"))])
        self.assertEqual(contract.unused, {"b"})
        self.assertEqual(contract.missing, frozenset())

    def test_probe_collects_all_misses_in_one_pass(self):
        # a real Theme raises on the first miss; the probe must not, so
        # every undefined reference surfaces together
        tokens = {"semantic": {}}
        adapter = lambda sem: sem.many("x", "y") and sem("z")
        self.assertEqual(check(tokens, [(None, adapter)]).missing, {"x", "y", "z"})


if __name__ == "__main__":
    unittest.main()
