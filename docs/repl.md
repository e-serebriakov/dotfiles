# REPL workflows

Helix and Neovim type selected code into the `REPL` pane of the current Rex session.
Neovim uses Conjure instead for Clojure.
Results appear there, and definitions persist between evaluations.
Each project session has its own REPL.

## Rex layout

The `work` tab of a `dev` session ([Rex guide](../packages/rex/.config/rex/README.md)) opens `hx .` above a shell on the left,
with an agent pane on the right.
The shell below Helix is the `REPL` pane. Start your REPL there.
Use `Alt+j` / `Alt+k` to focus the REPL / Helix panes.
The `feedback` tab contains logs and shell panes.

The editor finds the pane by its `REPL` label.
In a session without a `REPL` pane, the editor shows an error.

## Helix

Open a project with `dev`.
In the `REPL` pane, start your project's REPL. For example, start Babashka:

```sh
bb repl
```

Babashka supports a subset of Clojure, not a JVM project runtime.
Open a Clojure file in Helix and enter:

```clojure
(def answer 41)
(inc answer)
```

Press Escape. On each line, press `Space t l` to evaluate it.
The second evaluation prints `42`.

| Action | Keys |
| --- | --- |
| Evaluate selection (Tools → Evaluate) | `Space t e` |
| Evaluate the current line | `Space t l` |
| Select multiline code | `v`, then movement keys |
| Expand syntax selection | `Alt+o` |
| Interrupt evaluation | `Ctrl+c` in the REPL |

Evaluation does not save or modify the source. Select complete forms.
For Clojure, evaluate the buffer's `ns` form first to set its namespace and aliases.
Run `:config-reload` to load bindings into an existing Helix instance.

## Neovim

Python, TypeScript, and TSX buffers use `,E` in Visual mode to send selections
to the `REPL` pane. Select lines with `V`, or text with `v`.
The mapping leaves the source and registers unchanged.
Clojure retains Conjure's existing nREPL mappings.

Start the matching interpreter yourself. The buffer language does not select
the destination. Restart Neovim after updating this mapping.

For a TypeScript project with `tsx` installed, run in the `REPL` pane:

```sh
pnpm exec tsx
```

This evaluates TypeScript in Node, without browser state or the DOM.

## Other runtimes

To change the runtime, stop the REPL in the `REPL` pane and start another one.
Evaluate with `Space t e` in Helix or Visual-mode `,E` in Neovim for
Python and TypeScript.

### JVM Clojure

With Java and the Clojure CLI installed, run in the `REPL` pane:

```sh
clojure -M
```

Add your project's aliases as needed.
