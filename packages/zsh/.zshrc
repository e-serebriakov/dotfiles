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

# ensure target exists (safe no-op if already exists)
[[ -d ${HISTFILE:h} ]] || mkdir -p -- ${HISTFILE:h}
[[ -e $HISTFILE ]] || : >| $HISTFILE

# Completion
autoload -Uz compinit && compinit

# Plugins
if [[ -d ~/.local/share/zsh/zsh-syntax-highlighting/ ]]; then
  source ~/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
if [[ -d ~/.local/share/zsh/zsh-history-substring-search/ ]]; then
  source ~/.local/share/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi
if [[ -d ~/.local/share/zsh/zsh-autosuggestions/ ]]; then
  source ~/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Environment
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim
export COLORTERM=truecolor

if command -v devbox >/dev/null 2>&1; then
  eval "$(devbox global shellenv)"
fi

# fzf integration (Ctrl+R history, Ctrl+T files, Alt+C cd)
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh 2>/dev/null)" || { [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh; }
fi

# Git aliases
alias g='git'
alias gst='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gp='git push'
alias ggp='git push origin HEAD'
alias gl='git pull'
alias ggl='git pull origin HEAD'
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

# ===== ssh-agent autostart with multiple keys =====
_ssh_quiet_init() {
  if [ -z "$SSH_AUTH_SOCK" ] || ! [ -S "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
  fi

  if [ -S "$SSH_AUTH_SOCK" ]; then
    local SSH_KEYS=(
      "$HOME/.ssh/auth"
      "$HOME/.ssh/gh_auth"
      "$HOME/.ssh/sign"
    )

    for key in "${SSH_KEYS[@]}"; do
      if [ -f "$key" ]; then
        ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "$key" | awk '{print $2}')" || \
          ssh-add "$key" 2>/dev/null
      fi
    done
  fi
}
_ssh_quiet_init
unset -f _ssh_quiet_init

# Prompt
if command -v starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
elif [ -f ~/.local/bin/starship ]; then
  eval "$(~/.local/bin/starship init zsh)"
fi

if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi
