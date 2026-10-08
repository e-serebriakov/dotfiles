# Helix REPL

Helix sends selected code through reple to a persistent REPL in another pane.
Results appear there, and definitions persist between evaluations.
Run only one reple session at a time.

## Babashka in Zellij

From your project directory, start a session:

```sh
zellij --layout repl
```

Inside Zellij, open a tab instead:

```sh
zellij action new-tab --layout repl --name repl
```

Helix opens `repl-scratch.clj` on the left, with Babashka on the right.
The file is created when saved. Babashka supports a subset of Clojure, not a JVM
project runtime.

Enter:

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
| Focus REPL / Helix | `Alt+l` / `Alt+h` |
| Interrupt evaluation | `Ctrl+c` in the REPL |

Evaluation does not save or modify the source. Select complete forms.
For Clojure, evaluate the buffer's `ns` form first to set its namespace and aliases.
Run `:config-reload` to load bindings into an existing Helix instance.
Close the REPL pane with Zellij's pane controls when finished.
Restart the REPL after an abnormal termination.

## Other runtimes

Stop the existing reple session first. Use ordinary terminal panes instead of
this layout, which starts Babashka automatically. The evaluation binding stays
`Space t e`.

### JVM Clojure

With Java and the Clojure CLI installed, run:

```sh
reple spawn 'clojure -M'
```

Add your project's aliases as needed.

### Django in Docker

Open two panes in your project's Compose directory. Run Helix in one:

```sh
hx scratch.py
```

Start the Django shell in the other:

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

See the [research notes](helix-repl-research.md) for sources and alternatives.

[compose-exec]: https://docs.docker.com/reference/cli/docker/compose/exec/
[django-shell]: https://docs.djangoproject.com/en/5.2/ref/django-admin/#shell
