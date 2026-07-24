# Loaded for every shell — interactive or not, login or not.
typeset -U path PATH

path=("$HOME/.local/bin" $path)
export PATH

export EDITOR=nvim
export VISUAL=nvim
export COLORTERM=truecolor
