# zsh reads this file for all shells, including noninteractive and non-login shells.
typeset -U path PATH

path=("$HOME/.local/bin" /opt/homebrew/bin $path)
export PATH

export EDITOR=hx
export VISUAL=hx
export COLORTERM=truecolor
