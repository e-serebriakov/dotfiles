# REPL workflows

Helix and Neovim send selected code through reple to a persistent REPL in another
terminal. Neovim uses Conjure instead for Clojure.
Results appear there, and definitions persist between evaluations.
Run only one reple session at a time.

## Helix

From your project directory, start Helix:

```sh
hx .
```

In another terminal, open the same directory and start your project's REPL.
For example, start Babashka:

```sh
reple spawn 'bb repl'
```

Babashka supports a subset of Clojure, not a JVM project runtime.
Open a Clojure file in Helix and enter:

```clojure
(def answer 41)
(inc answer)
```

Press Escape. Select each line with `x`, then press `Space t e` to evaluate it.
The second evaluation prints `42`.

| Action | Keys |
| --- | --- |
| Evaluate selection (Tools → Evaluate) | `Space t e` |
| Select multiline code | `v`, then movement keys |
| Expand syntax selection | `Alt+o` |
| Interrupt evaluation | `Ctrl+c` in the REPL |

Evaluation does not save or modify the source. Select complete forms.
For Clojure, evaluate the buffer's `ns` form first to set its namespace and aliases.
Run `:config-reload` to load bindings into an existing Helix instance.
Restart the REPL after an abnormal termination.

## Neovim

Python, TypeScript, and TSX buffers use `,E` in Visual mode to send selections
to the same external reple process. Select lines with `V`, or text with `v`.
The mapping leaves the source and registers unchanged.
Clojure retains Conjure's existing nREPL mappings.

Start the matching interpreter yourself. The buffer language does not select
the destination. Restart Neovim after installing reple or updating this mapping.

For a TypeScript project with `tsx` installed, run from its directory:

```sh
reple spawn 'pnpm exec tsx'
```

This evaluates TypeScript in Node, without browser state or the DOM.

## Other runtimes

Stop the existing reple session before starting another runtime.
Evaluate with `Space t e` in Helix or Visual-mode `,E` in Neovim for
Python and TypeScript.

### JVM Clojure

With Java and the Clojure CLI installed, run:

```sh
reple spawn 'clojure -M'
```

Add your project's aliases as needed.

## Install on another machine

Repository setup installs the dependencies. After linking these dotfiles,
install only the new dependencies with:

```sh
mise install --locked go go:github.com/j3ka/reple
```

## Optional Zellij layout

From your project directory, run `zellij --layout repl`.
The `work` tab opens `hx .` above a shell on the left, with an agent pane on the right.
Start your REPL in the shell below Helix.
Use `Alt+j` / `Alt+k` to focus the REPL / Helix panes.
The `feedback` tab contains logs and shell panes, as in the `work` layout.
