# Loaded for login shells, before .zshrc.

# python.org framework install. mise also provides python and activates later in
# .zshrc, so mise wins — this only matters when invoking it by path.
if [[ -d /Library/Frameworks/Python.framework/Versions/3.12/bin ]]; then
  path=(/Library/Frameworks/Python.framework/Versions/3.12/bin $path)
  export PATH
fi

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
