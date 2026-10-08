# REPL workflows

Helix and Neovim send selected code through reple to a persistent REPL in another
pane. Neovim uses Conjure instead for Clojure.
Results appear there, and definitions persist between evaluations.
Run only one reple session at a time.

## Helix in Zellij

From your project directory, start a session:

```sh
zellij --layout repl
```

The `work` tab has Helix above a shell on the left and an agent pane on the
right. Helix opens the current directory with `hx .`.
Start your project's REPL in the shell below Helix.
The `feedback` tab contains logs and shell panes, as in the `work` layout.

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
| Focus REPL / Helix | `Alt+j` / `Alt+k` |
| Interrupt evaluation | `Ctrl+c` in the REPL |

Evaluation does not save or modify the source. Select complete forms.
For Clojure, evaluate the buffer's `ns` form first to set its namespace and aliases.
Run `:config-reload` to load bindings into an existing Helix instance.
Close the REPL pane with Zellij's pane controls when finished.
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
The Django command below works with Neovim as well as Helix.

## Other runtimes

Stop the existing reple session before starting another runtime in the shell
pane. Evaluate with `Space t e` in Helix or Visual-mode `,E` in Neovim for
Python and TypeScript.

### JVM Clojure

With Java and the Clojure CLI installed, run:

```sh
reple spawn 'clojure -M'
```

Add your project's aliases as needed.

### Django in Docker

Start the layout from your project's Compose directory:

```sh
zellij --layout repl
```

Open a Python file in Helix. Start the Django shell in the pane below it:

```sh
reple spawn 'docker compose exec cmd python manage.py shell'
```

Replace `cmd` with your service name. The container must be running, with
`manage.py` in its working directory. Do not add `-T`.
Helix and reple run on the host. Django runs in the container.

Select and evaluate these statements in order:

```python
from django.contrib.auth import get_user_model
User = get_user_model()
User.objects.count()
```

Django selects Python, IPython, or bpython based on installed packages.
Use `shell -i python` to select standard Python explicitly.
Reple sends raw text. Multiline Python blocks can need a terminating blank line
or interpreter-specific paste handling.

The Docker workflow has not been tested against a Django project here.
See [Compose exec][compose-exec] and [Django shell][django-shell].

## Install on another machine

Repository setup installs the dependencies. After linking these dotfiles,
install only the new dependencies with:

```sh
mise install --locked go go:github.com/j3ka/reple
```

[compose-exec]: https://docs.docker.com/reference/cli/docker/compose/exec/
[django-shell]: https://docs.djangoproject.com/en/5.2/ref/django-admin/#shell
