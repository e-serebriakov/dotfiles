# History
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.local/share/history/histfile
setopt appendhistory
setopt inc_append_history
setopt hist_ignore_all_dups   
setopt share_history 
setopt extended_history
setopt hist_expire_dups_first
setopt hist_save_no_dups
setopt hist_ignore_space

# ensure target exists (safe no-op if already exists)
[[ -d ${HISTFILE:h} ]] || mkdir -p -- ${HISTFILE:h}
[[ -e $HISTFILE ]] || : >| $HISTFILE

# Completion
autoload -Uz compinit && compinit

# Plugins
if [[ -d ~/.local/share/zsh/fzf-tab/ ]]; then
  source ~/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh
fi
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

# fzf integration (Ctrl+R history, Ctrl+T files, Alt+C cd)
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh 2>/dev/null)" || { [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh; }
fi
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 {}'"

# CLI aliases
alias cat='bat'
alias ls='eza'
alias ll='eza -la --git'
alias tree='eza --tree'

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
alias glp='git log --patch'
alias gwip='git commit -am "wip" --no-verify'
alias gunwip='git log -1 --format="%s" | grep -q "^wip$" && git reset HEAD~1'

# Git Town aliases
alias gts='git town sync'
alias gta='git town append'
alias gtp='git town propose'
alias gtsh='git town ship'
alias gtdp='git town diff-parent'
alias gtl='git town status'
alias gth='git town hack'

# PR review from terminal — `pr` for own PRs, `pr 123` for specific PR
pr() {
  local num=${1:-$(gh pr list --author @me --state open --json number,title \
    | jq -r '.[] | "\(.number)\t\(.title)"' | fzf --prompt="PR> " | cut -f1)}
  [[ -z "$num" ]] && return 1
  gh pr view "$num" && gh pr diff "$num" | delta
}

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
eval "$(mise activate zsh)"
eval "$(zoxide init zsh)"

# Zellij project launcher — attach if session exists, create with work layout if not
# Usage: dev              (use current dir as project)
#        dev <project>    (resolve dir via zoxide)
dev() {
  if [[ -n "$ZELLIJ" ]]; then
    echo "dev: already inside zellij — use Ctrl+o w (session manager) to switch" >&2
    return 1
  fi

  local project dir

  if [[ -z "$1" ]]; then
    project="${PWD:t}"
    dir="$PWD"
  else
    project="$1"
    dir="$(zoxide query "$project" 2>/dev/null)" || {
      echo "dev: could not resolve '$project' — cd there once so zoxide learns it" >&2
      return 1
    }
  fi

  zellij attach "$project" 2>/dev/null || (cd "$dir" && zellij -s "$project" -n work)
}
_dev() {
  local -a sessions dirs
  sessions=(${(f)"$(zellij list-sessions 2>/dev/null | awk '{print $1}')"})
  dirs=(${(f)"$(zoxide query -l 2>/dev/null | while read -r d; do echo "${d:t}"; done)"})
  _alternative "sessions:sessions:(${sessions})" "dirs:directories:(${dirs})"
}
compdef _dev dev

alias rootpls='/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI --add'
alias gg='/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI --remove'
