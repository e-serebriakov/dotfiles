# zsh reads this file for all shells, including noninteractive and non-login shells.
typeset -U path PATH

path=("$HOME/.local/bin" /opt/homebrew/bin $path)
export PATH

export EDITOR=nvim
export VISUAL=nvim
export COLORTERM=truecolor
