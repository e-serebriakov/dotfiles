# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.local/share/history/histfile
setopt appendhistory
setopt inc_append_history
setopt hist_ignore_all_dups   
setopt share_history 
setopt extended_history
setopt hist_expire_dups_first 
setopt hist_ignore_space 

# Plugins
if [[ -d ~/.local/share/zsh/zsh-syntax-highlighting/ ]]; then
  source ~/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
if [[ -d ~/.local/share/zsh/zsh-history-substring-search/ ]]; then
  source ~/.local/share/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
fi
if [[ -d ~/.local/share/zsh/zsh-autosuggestions/ ]]; then
  source ~/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

export PATH="~/.local/bin/:$PATH"

alias g='git'
alias gst='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gp='git push'
alias ggp='git push origin $(current_branch)'
alias gl='git pull'
alias ggl='git pull origin $(current_branch)'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gm='git merge'
alias gr='git remote'
alias grv='git remote -v'
alias gcl='git clone'
alias gd='git diff'
alias gds='git diff --staged'
alias gb='git branch'
alias gba='git branch -a'
alias gpo='git push origin'
alias glog='git log --oneline --graph --decorate'
alias gss='git stash show'
alias gsta='git stash'
alias gstp='git stash pop'
alias gsp='git show'
alias gt='git tag'
alias grh='git reset'

# ===== ssh-agent autostart with multiple keys (robust) =====
if [ -z "$SSH_AUTH_SOCK" ] || ! [ -S "$SSH_AUTH_SOCK" ]; then
  echo "[ssh-init] ssh-agent not running, starting new one..."
  eval "$(ssh-agent -s)" > /dev/null
fi

if [ -S "$SSH_AUTH_SOCK" ]; then
  SSH_KEYS=(
    "$HOME/.ssh/auth"
    "$HOME/.ssh/gh_auth"
    "$HOME/.ssh/sign"
  )

  for key in "${SSH_KEYS[@]}"; do
    if [ -f "$key" ]; then
      if ! ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "$key" | awk '{print $2}')" ; then
        ssh-add "$key" > /dev/null && echo "[ssh-init] Added: $key"
      fi
    else
      echo "[ssh-init] A key was not found: $key" >&2
    fi
  done
else
  echo "[ssh-init] ssh-agent socket not found or invalid: $SSH_AUTH_SOCK" >&2
fi

# Prompt
if command -v starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
elif [ -f ~/.local/bin/starship ]; then
  eval "$(~/.local/bin/starship init zsh)"
fi

if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

if command -v devbox >/dev/null 2>&1; then
  eval "$(devbox global shellenv --init-hook)"
fi

