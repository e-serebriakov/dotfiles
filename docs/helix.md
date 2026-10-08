# Helix development

Keep editor preferences in dotfiles. Select language tools per project through
`.helix/languages.toml`, project mise settings, and existing dependencies.
Helix merges project language settings with its global configuration.
See the [language configuration reference][languages].

## Project setup

Run `hx .` from the project directory. Configure that project's language servers
and formatters in `.helix/languages.toml`. Keep runtime versions, dependency
installation commands, and project-specific paths with the project.

Formatting and import organization are separate operations. For Biome projects,
`biome check --write` applies formatting, import organization, and safe fixes.
A formatting-only request does not apply all of these actions.

Helix runs external formatters from the file's directory. Its `%{buffer_name}`
expansion can be relative to the editor's working directory. Account for this
when passing filenames to formatter commands.

Helix 25.07.1 lacks the pull-diagnostic support required by some language servers.
Check compatibility before selecting a server. See
[Helix's development documentation][pull-diagnostics].

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
