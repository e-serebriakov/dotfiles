"""delta (git diffs) adapter: colour styles only.

syntax-theme = ansi routes diff *foreground* highlighting through the terminal's
own ANSI palette (themed from these same tokens), so diffs use one calm palette
instead of a foreign bat theme fighting the diff tints.
"""

from theme.engine import GENERATED_BANNER, ROOT

OUTPUT = ROOT / "packages/git/.config/delta/ergo-light.gitconfig"


def render(sem):
    return f"""; {GENERATED_BANNER}
; Color styles only; behavioural delta settings live in the committed .gitconfig.
[delta]
    syntax-theme = ansi
    plus-style = "syntax {sem("diff.add")}"
    plus-emph-style = "syntax {sem("diff.addText")}"
    minus-style = "syntax {sem("diff.delete")}"
    minus-emph-style = "syntax {sem("diff.deleteText")}"
    hunk-header-style = "{sem("text.secondary")}"
    hunk-header-decoration-style = "{sem("border.default")} ul"
    file-style = "{sem("text.primary")} bold"
    file-decoration-style = "{sem("border.default")} ul"
    line-numbers-minus-style = "{sem("status.error")}"
    line-numbers-plus-style = "{sem("status.success")}"
    line-numbers-zero-style = "{sem("text.muted")}"
"""
