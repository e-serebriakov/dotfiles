# Theme — Ergo Light

![The Ergo Light theme rendered in itself — comments, syntax, a selection, search matches, an error mark, and a diff](preview.svg)

One source of colour, many tools. Everything above is drawn from a single
token file and re-tuned into each tool's own format.

## How it works

All colour lives in **one file** — [`ergo-light.tokens.json`](ergo-light.tokens.json) —
tool-agnostic [design tokens](https://tr.designtokens.org/) in two layers:

- **primitives** — raw OKLCH ramps
- **semantic** — named roles aliased onto primitives (`accent.string`,
  `diff.add`, `status.error`, …)

No tool reads the tokens directly. Each tool has a small *generator* that maps
the semantic layer onto that tool's own keys, emitting:

| Tool | Generator | Generated file |
| --- | --- | --- |
| Neovim | [`generators/nvim.py`](generators/nvim.py) | `colorschemes/ergo_light_palette.lua` |
| WezTerm | [`generators/wezterm.py`](generators/wezterm.py) | `colors/ergo_light.toml` |
| Zellij | [`generators/zellij.py`](generators/zellij.py) | `themes/ergo-light.kdl` |
| delta (git diffs) | [`generators/delta.py`](generators/delta.py) | `delta/ergo-light.gitconfig` |
| Helix | [`generators/helix.py`](generators/helix.py) | `themes/ergo_light.toml` |

Those five are **gitignored build artifacts** — never hand-edit them; they're
regenerated on every `install.sh`. `preview.svg` is the one *tracked* output
(so it renders on GitHub); it's generated too, so don't hand-edit it either.

### Layout

- [`engine.py`](engine.py) — the tool-agnostic core: resolves the token graph
  into a `Theme` (`sem('surface.base')`) and holds the tokens↔generator contract.
- [`generators/`](generators/) — one module per tool, each exposing `OUTPUT`
  (its path) and `render(sem)`. [`__init__.py`](generators/__init__.py) collects
  them into the `ADAPTERS` array the engine drives. `preview.py` lives here too
  (see below), deliberately outside `ADAPTERS`.
- [`generate.py`](generate.py) — the CLI: runs the contract check, then writes
  every output.

## Working on the theme

```sh
# Edit the tokens, then regenerate every output (install.sh also does this):
python3 theme/generate.py

# Preview it right in the terminal (truecolor ANSI, writes nothing):
python3 theme/generate.py --preview

# Verify: contract (adapters only reference tokens that exist) + golden outputs:
python3 -m unittest theme.test_generate
```

`--preview` prints the same mock as `preview.svg` above using 24-bit-colour
escapes — handy over ssh or in a `:terminal` split, and the fastest way to eyeball
a token change without opening any tool. Both previews render from one shared
definition, so they can't drift. (In a truecolor terminal: WezTerm, kitty, recent
tmux; the error undercurl needs WezTerm/kitty and degrades to an underline
elsewhere.)

![`--preview` running in WezTerm](preview-terminal.png)

_(A real capture, so — unlike `preview.svg` — it won't auto-update; recapture it
after a major retune.)_

Reload the tool and the whole environment re-tunes together.

**Add a tool:** drop a `generators/<tool>.py` exposing `OUTPUT` and `render(sem)`,
add one row to `ADAPTERS` in `generators/__init__.py`, and gitignore its output.
Nothing in `engine.py` or `generate.py` changes. The contract test guards that
generators reference only real tokens, and flags tokens no generator consumes.

Tools that aren't generated (ccstatusline, starship, git's own output) use
**named ANSI colours**, so they follow the terminal palette — itself themed
from these tokens — automatically.
