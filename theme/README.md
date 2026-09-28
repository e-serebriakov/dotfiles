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
| Neovim | [`generators/nvim.clj`](generators/nvim.clj) | `colorschemes/ergo_light_palette.lua` |
| WezTerm | [`generators/wezterm.clj`](generators/wezterm.clj) | `colors/ergo_light.toml` |
| Zellij | [`generators/zellij.clj`](generators/zellij.clj) | `themes/ergo-light.kdl` |
| delta (git diffs) | [`generators/delta.clj`](generators/delta.clj) | `delta/ergo-light.gitconfig` |
| Helix | [`generators/helix.clj`](generators/helix.clj) | `themes/ergo_light.toml` |

Those five are **gitignored build artifacts** — never hand-edit them; they're
regenerated on every `install.sh`. `preview.svg` is the one *tracked* output
(so it renders on GitHub); it's generated too, so don't hand-edit it either.

### Layout

- [`engine.clj`](engine.clj) — the tool-agnostic core: resolves the token graph
  into a `theme` fn (`(theme "surface.base")`) and holds the tokens↔generator
  contract.
- [`generators/`](generators/) — one namespace per tool, each exposing `render`.
  [`generate.clj`](generate.clj) collects them into the `adapters` vector it
  drives. `preview.clj` lives here too (see below), deliberately outside
  `adapters`.
- [`generate.clj`](generate.clj) — the CLI: runs the contract check, then writes
  every output.

## Working on the theme

```sh
# Edit the tokens, then regenerate every output (install.sh also does this):
(cd theme && bb -m generate)

# Preview it right in the terminal (truecolor ANSI, writes nothing):
(cd theme && bb -m generate --preview)

# Verify: contract (adapters only reference tokens that exist) + golden outputs:
(cd theme && bb -m generate && bb test)
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

**Add a tool:** drop a `generators/<tool>.clj` exposing `render`, add one row to
the `adapters` vector in `generate.clj`, and gitignore its output. Nothing in
`engine.clj` changes. The contract test guards that
generators reference only real tokens, and flags tokens no generator consumes.

Tools that aren't generated (ccstatusline, starship, git's own output) use
**named ANSI colours**, so they follow the terminal palette — itself themed
from these tokens — automatically.
