# zsh loads this file for login shells before .zshrc.

# path_helper in /etc/zprofile reorders PATH; put .zshenv's directories first again.
path=("$HOME/.local/bin" /opt/homebrew/bin $path)

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
