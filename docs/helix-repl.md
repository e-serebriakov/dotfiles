# Try Helix with a REPL

This setup uses standard Helix, reple, and a persistent Babashka REPL in Zellij.
Babashka runs a subset of Clojure. It does not replace a JVM project runtime.

## Start

Open a new terminal in your project directory. Run:

```sh
zellij --layout repl
```

Inside an existing Zellij session, create a tab instead:

```sh
zellij action new-tab --layout repl --name repl
```

Helix opens `repl-scratch.clj` on the left. Babashka starts on the right.
The scratch file is created only when you save it.

## Evaluate code

Enter these forms in Helix:

```clojure
(def answer 41)
(inc answer)
```

Press Escape. Select the first line with `x`. Press `Space t e` to evaluate it.
Select the second line and press `Space t e` again. The REPL prints `42`.
The second evaluation uses the definition from the first evaluation.

The mnemonic is **Tools → Evaluate**. `Space e` retains Helix's file explorer.
Helix 25.07.1 cannot display a custom group description for `Space t`.

Select complete forms with `v` and movement keys for multiline code.
Use `Alt+o` to expand a syntax selection when useful.
`Space t e` sends the selection without changing the source or saving the file.
Run `:config-reload` if Helix was open before these bindings were added.

Use `Alt+l` to focus the REPL and `Alt+h` to return to Helix.
Press `Ctrl+c` in the REPL to interrupt evaluation.
Close the REPL pane with Zellij's pane controls when finished.

## Limits and other runtimes

Run only one reple session at a time. Its input channel is shared.
Start the REPL before sending code. Restart it after an abnormal termination.
Selections run in the REPL's current namespace.
Evaluate the buffer's `ns` form first when you need its namespace and aliases.

For a JVM Clojure project, start its REPL through reple in a terminal pane:

```sh
reple spawn 'clojure -M'
```

This requires Java and the Clojure CLI. Add your project's aliases as needed.
Stop the Babashka reple session before starting this command.
Helix uses the same `Space t e` binding for either runtime.

Results stay in the REPL pane. This setup does not provide an editor inspector
or automatic namespace synchronization.

## Django inside Docker

This workflow keeps Helix and reple on the host.
The persistent Django shell runs inside an existing Compose container.
You do not need reple inside the container.

Stop any existing reple session first.
Open two terminal panes in your project's Compose directory.
The `repl` layout starts Babashka automatically, so use ordinary panes here.

In the editor pane, run:

```sh
hx scratch.py
```

In the REPL pane, run:

```sh
reple spawn 'docker compose exec cmd python manage.py shell'
```

Replace `cmd` with your Compose service name.
The container must already be running.
Its working directory must contain `manage.py`.
Keep the default interactive terminal allocation. Do not add `-T`.

Enter these statements in Helix:

```python
from django.contrib.auth import get_user_model
User = get_user_model()
User.objects.count()
```

Select each statement and press `Space t e`.
Imports and variables persist between evaluations.
Results appear in the Django terminal pane.

Django can select Python, IPython, or bpython, depending on installed packages.
Use `shell -i python` to request the standard Python interpreter explicitly.
Multiline blocks can require a terminating blank line or interpreter-specific
paste handling. Reple sends raw text without Python paste preprocessing.
Test small selections before sending larger blocks.

This Docker workflow follows the tools' documented behavior.
It has not been tested against a Django project in this repository.
See [Compose exec](https://docs.docker.com/reference/cli/docker/compose/exec/)
and the [Django shell documentation][django-shell].

[django-shell]: https://docs.djangoproject.com/en/5.2/ref/django-admin/#shell

## Installation on another machine

The repository setup installs Go and reple through mise.
After linking these dotfiles, you can install only the new dependencies:

```sh
mise install --locked go go:github.com/j3ka/reple
```

See the [research notes](helix-repl-research.md) for sources and alternatives.
