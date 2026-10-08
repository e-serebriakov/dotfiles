# Helix REPL development

Research date: October 8, 2026.

People use Helix for development against persistent REPL processes, including
Clojure.
Standard Helix users send selections to external terminals or helper programs.
The Steel-enabled fork also supports an integrated nREPL client.
Published configurations and personal reports demonstrate usage, but they do not
establish broad adoption or reliability.

## Standard Helix: send selections to a running REPL

Helix provides `:pipe-to`, which sends selected text to an external command.
Unlike `:pipe`, this does not replace the selection with command output.
A helper can forward that input to an existing interpreter.
The interpreter preserves definitions and application state between evaluations.
See the [Helix command reference][1].

This distinction matters: starting a fresh interpreter for each selection does
not provide the same persistent development environment.
The approaches below target an existing process.

### Clojure with reple

The [reple repository][2] provides an explicit Helix configuration:

```toml
[keys.normal]
"A-ret" = ":pipe-to reple eval"

[keys.select]
"A-ret" = ":pipe-to reple eval"
```

Start the interpreter through `reple spawn` in another terminal.
Select code in Helix and press Alt+Enter.
The external terminal receives the code and displays the result.
The README lists simultaneous REPL support as unfinished work.

There is direct evidence of Clojure usage.
In a [first-person discussion][3],
the author discussing his nREPL and Paredit plugins reports previously using
reple for Clojure.
This is stronger evidence than a generic claim that any editor can send text to
a terminal.

Assessment: this supports selection evaluation without a Helix fork.
It does not establish automatic namespace selection, editor result buffers, or
CIDER-style inspection.
Those features require more than forwarding terminal input.

### Python with tmux

A [user's published workflow][4]
binds Ctrl+E to send selected lines to an existing IPython process.
The helper finds a tmux pane, loads stdin into a tmux buffer, and pastes with
bracketed paste enabled.
It then sends Enter.

The user supplies both the helper script and Helix bindings.
This demonstrates repeated evaluation in an external process, with results
visible in that terminal.
Pane discovery depends on titles and working directories, so the published
implementation needs careful matching in larger sessions.

### Julia with WezTerm

[Mauro Werder's configuration][5], dated August 7, 2025,
uses WezTerm's command-line interface to send code to the pane on the right.
His bindings evaluate lines, selections, functions, paragraphs, and complete
Julia files.
The startup helper also handles Python and MATLAB.

He reports using Helix for a year, but qualifies the evaluation setup as having
limited coding mileage.
The published configuration does not support multiple cursors.
Its fixed pane direction also constrains the terminal layout.

### Python with Zellij

[Clement Poiret's January 20, 2025 article][6]
describes a Python setup that he uses daily.
Helix sends selections through `:pipe-to` to a persistent ptpython process in
Zellij.
His helper uses Zellij's `write-chars` command, and DevEnv starts the project
environment.

The published recipe changes pane focus and assumes a relative pane layout.
This is direct evidence for the terminal multiplexer already managed in these
dotfiles.
Adapting it to Clojure still requires decisions about complete forms and
namespace context.

### A reusable helper for Zellij and tmux

The [replink author][7] built a command-line helper specifically for this Helix
workflow.
It handles differences in Python REPL paste behavior and supports tmux and
Zellij.
Helix passes selections through `:pipe-to`.

Its documented language support is currently Python.
It is evidence that this integration pattern has reusable tooling, but it is not
a documented Clojure solution.

## Steel fork: integrated Clojure evaluation

[Tom Waddington reports][8]
using his Helix Clojure setup as his daily editor.
His article includes demonstrations and explains the selection-first evaluation
model.

The [nrepl.hx README][9] documents:

- Connecting to an existing nREPL server or starting one for a project.
- Evaluating selections, multiple selections, buffers, and files.
- Displaying results in a dedicated `*nrepl*` buffer.
- Interrupting evaluation and choosing server sessions.
- Clojure, Babashka, and some ClojureScript workflows.

The plugin requires Matthew Paras's `steel-event-system` Helix fork.
Its ClojureScript support has limits, including no Figwheel support or `.cljc`
session cloning.
The README documents commands, but this research did not independently exercise
them.

The older article describes missing interruption support.
The current README lists `:nrepl-interrupt`, so that older limitation should not
be repeated as current fact.

The author's [project list][10] also documents `paredit.hx`.
It provides Lisp structural operations such as slurp, barf, raise, and splice
through the Steel system.

The [upstream Steel pull request][11] remains a draft at the research date.
The [fork's build instructions][12]
use `cargo xtask steel` to install Helix and the supporting Steel tools.
This is an experimental editor distribution, not an extension for the installed
standard binary.

## What the two approaches provide

| Requirement | Standard Helix + helper | Steel + nrepl.hx |
| --- | --- | --- |
| Persistent program | External REPL | nREPL server |
| Selection evaluation | Yes | Yes |
| Results in Helix | No | Result buffer |
| Connection management | External tools | Plugin commands |
| Clojure runtime tooling | Manual or extra tools | Protocol integration |
| Standard Helix binary | Yes | No |

The table summarizes the cited implementations, not every possible Helix
customization.
Sending complete Clojure forms is necessary for useful evaluation.
Terminal forwarding alone does not associate source locations or buffer
namespaces with the submitted text.
An evaluation can therefore run in the wrong namespace unless the workflow
manages that context.

## Implications for these dotfiles

The repository already manages Helix, Zellij, and Babashka in its
[mise configuration][13].
The [Helix language configuration][14]
already selects `clojure-lsp` for Clojure files.
The [editor configuration][15] has no REPL bindings.

The preceding local check reported Helix 25.07.1 and could not find
`clojure-lsp` on PATH.
It also reported missing Clojure indentation and textobject queries.
These observations describe the local environment, not all Helix versions.

Recommendation: first try standard Helix with a persistent Clojure or Babashka
REPL in a Zellij pane.
Use a small input-forwarding integration or evaluate reple before adopting an
experimental editor build.
This recommendation follows from the existing tool choices and the published
workflows.
It is not a claim that a Clojure Zellij integration was tested here.

Consider the Steel fork if results inside Helix, automatic connection setup, and
structural Lisp editing justify maintaining it.
Do not assume an upstream release date from the existence of working plugins.

## Validation limits

This investigation reviewed official commands, project documentation, published
configurations, and first-person usage reports.
It did not install helpers, build the fork, or run an interactive REPL
integration.
The sources demonstrate feasibility and individual usage, not comparative
benchmarks or widespread adoption.
Only this research document was added.

[1]: https://docs.helix-editor.com/commands.html
[2]: https://github.com/j3ka/reple
[3]: https://www.reddit.com/r/HelixEditor/comments/1upxo3i/send_to_ipython_repl_using_tmux/
[4]: https://www.reddit.com/r/HelixEditor/comments/1upxo3i/send_to_ipython_repl_using_tmux/
[5]: https://maurow.bitbucket.io/notes/helix-julia-latex-setup.html
[6]: https://int8.tech/posts/repl-programming-helix-zellij-devenv/
[7]: https://github.com/a3lem/replink
[8]: https://www.tomwaddington.dev/helix-and-clojure.html
[9]: https://github.com/waddie/nrepl.hx
[10]: https://www.tomwaddington.dev/projects.html
[11]: https://github.com/helix-editor/helix/pull/8675
[12]: https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md
[13]: ../packages/mise/.config/mise/config.toml
[14]: ../packages/helix/.config/helix/languages.toml
[15]: ../packages/helix/.config/helix/config.toml
