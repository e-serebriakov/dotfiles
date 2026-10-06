# Themes

| Ergo Light (default) | TE calm |
| --- | --- |
| ![Ergo Light preview: comments, syntax, selection, search matches, error mark, and diff](preview-ergo-light.svg) | ![TE calm preview: comments, syntax, selection, search matches, error mark, and diff](preview-te-calm.svg) |

## Themes

| Theme | Tokens |
| --- | --- |
| Ergo Light (default) | [`ergo-light.tokens.json`](ergo-light.tokens.json): cool monochrome, muted accents |
| TE calm | [`te-calm.tokens.json`](te-calm.tokens.json): Teenage Engineering-inspired, lab-grey paper, saturation reserved for important signals |

Only one theme is active at a time. Switch with `bb -m generate --theme <name>`.
The choice is saved in `theme/.active`, which Git ignores, so `install.sh` regenerates the same theme.
Each theme has its own `preview-<name>.svg`, so switching themes never changes tracked files.

[`retro-options.html`](retro-options.html) is the design exploration that produced TE calm.
Open it in a browser to compare the two themes and export primitives for a new one.

## How it works

Each `*.tokens.json` file defines the colors as [design tokens](https://tr.designtokens.org/) in two layers:

- **Primitives:** OKLCH color scales.
- **Semantic tokens:** named roles that refer to primitives, such as `accent.string`, `diff.add`, and `status.error`.

Tools do not read the tokens directly. Each generator converts semantic tokens to the format for its tool:

| Tool | Generator | Generated file |
| --- | --- | --- |
| Neovim | [`generators/nvim.clj`](generators/nvim.clj) | `colorschemes/baked_palette.lua` |
| WezTerm | [`generators/wezterm.clj`](generators/wezterm.clj) | `colors/baked.toml` |
| Zellij | [`generators/zellij.clj`](generators/zellij.clj) | `themes/baked.kdl` |
| delta | [`generators/delta.clj`](generators/delta.clj) | `delta/baked.gitconfig` |
| Helix | [`generators/helix.clj`](generators/helix.clj) | `themes/baked.toml` |

Every generated file, and the theme name inside it, is called `baked` whichever theme is active.
That way the tool configs never change when you switch themes.

Git ignores these five files. `install.sh` regenerates them on each run.
The generator also creates one `preview-<name>.svg` per theme. Git tracks these files so GitHub can display them.
Do not edit generated files manually.

ccstatusline, Starship, and Git output use named ANSI colors from the terminal palette.
They follow the theme without separate generated files.

### Source files

- [`engine.clj`](engine.clj) resolves token references into the `theme` function, for example `(theme "surface.base")`.
  It also validates the contract between tokens and generators.
- [`generators/`](generators/) contains one namespace per tool. Each provides a `render` function.
  `preview.clj` is separate from `adapters` so preview-only references do not hide unused tool tokens.
- [`generate.clj`](generate.clj) registers tool generators in `adapters`, picks the theme, validates the contract, and writes all output files.

## Change the theme

Edit a token file, then run these commands from the repository root:

```sh
# Switch to another theme and regenerate all output files.
(cd theme && bb -m generate --theme te-calm)

# Regenerate the active theme. install.sh also runs this command.
(cd theme && bb -m generate)

# Show a 24-bit color preview in the terminal without writing files.
(cd theme && bb -m generate --preview)
(cd theme && bb -m generate --preview --theme te-calm)  # any theme; does not switch

# Validate every theme's token references and compare generated output with expected output.
(cd theme && bb -m generate && bb test)
```

Reload each tool to apply the new colors. In Neovim, run `:BakedReload`.

The terminal preview and the `preview-<name>.svg` images use the same sample definition.
Use `--preview` over SSH or in a Neovim `:terminal` window to inspect changes before reloading tools.
Use a terminal with 24-bit color support, such as WezTerm, kitty, or a recent tmux version.
The error mark uses a curved underline in WezTerm and kitty, and a straight underline elsewhere.

![Terminal preview in WezTerm](preview-terminal.png)

This screenshot does not update automatically. Replace it after major theme changes.

## Add a tool

1. Create `generators/<tool>.clj` with a `render` function.
2. Add the generator to `adapters` in `generate.clj`.
3. Add its output path to `.gitignore`.
4. Run the generation and test commands above.

No changes to `engine.clj` are needed.
The contract test checks for missing token references and unused tokens.
