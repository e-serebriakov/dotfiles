# Helix development

Keep editor preferences in dotfiles. Select language tools per project through
`.helix/languages.toml`, project mise settings, and existing dependencies.
Helix merges project language settings with its global configuration.
See the [language configuration reference][languages].

## Deltia

Start Helix from the repository:

```sh
cd ~/source_code/deltia/backend
hx .
```

The local `.helix/languages.toml` is ignored by Git. It uses absolute paths to
this checkout's tools. Update those paths if you move the checkout.

The frontend uses its installed TypeScript 7 server and Biome. Biome reads
`frontend/biome.json` for lint rules and formatting. No global TypeScript server
or formatter is required for these files. Install frontend dependencies before
starting Helix on another machine.

Python uses `ty` and Ruff from `backend/.venv`. Install or refresh that ignored
environment from the existing lockfile:

```sh
cd backend
uv sync --locked --group dev --no-install-project
```

No activation is needed for Helix. Its local configuration names these tools
explicitly. Django dependency navigation uses files in `.venv`. Keep the Django
REPL in Docker so it uses the application's runtime settings and services.

Helix 25.07.1 does not support the pull diagnostics used by TypeScript 7 and
`ty`. Hover and Python dependency navigation work, and Biome supplies lint
diagnostics. Run `just analyze` for TypeScript errors, or
`backend/.venv/bin/ty check backend` for Python errors, until upgrading Helix.
Pull-diagnostic support is present in [Helix's development documentation][pull-diagnostics].

JavaScript, TypeScript, JSX, and TSX run `biome check --write` on save or
`:format`. This formats code, organizes imports, and applies safe fixes.
The command runs from the file's directory to discover the project configuration.
JSON and CSS use Biome's language-server formatter. Additional lint actions
remain available through `Space a`.

## Daily controls

| Action | Keys or command |
| --- | --- |
| Find files / search project | `Space f` / `Space /` |
| Browse files | `Space e` |
| Definition / references | `g d` / `g r` |
| Hover documentation | `Space k` |
| Rename symbol / code actions | `Space r` / `Space a` |
| Next / previous diagnostic | `] d` / `[ d` |
| Buffer / workspace diagnostics | `Space d` / `Space D` |
| Format buffer | `:format` |
| Save without formatting | `:write --no-format` |
| Restart language servers | `:lsp-restart` |
| Evaluate selection | `Space t e` |

Restart Helix after changing language settings. Run `hx --health tsx` or
`hx --health python` from the project directory to check tool discovery.

See [REPL workflows](repl.md) for runtime commands and selection examples.
Use another Zellij pane for tests, Git commands, and development servers.

## Remaining differences

REPL evaluation sends text to one shared reple session. It does not provide
Conjure's nREPL integration. Helix also lacks this Neovim configuration's Paredit
mappings and configured debugger workflows.

[languages]: https://docs.helix-editor.com/languages.html

[pull-diagnostics]: https://github.com/helix-editor/helix/blob/master/book/src/languages.md
