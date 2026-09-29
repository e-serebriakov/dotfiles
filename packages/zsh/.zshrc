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
setopt interactive_comments

[[ -d ${HISTFILE:h} ]] || mkdir -p -- ${HISTFILE:h}
[[ -e $HISTFILE ]] || : >| $HISTFILE

# mise puts starship, fzf, zoxide and the rest on PATH, so it has to run before
# anything that probes for them.
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# Completion — rebuild dump at most once a day for faster startup
# (a glob inside [[ ]] never expands, so loop over the qualified match instead)
autoload -Uz compinit
for _dump in ~/.zcompdump(N.mh+24); do compinit; done
compinit -C
unset _dump

# Case-insensitive completion; preview directory contents when completing cd.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Plugins — order matters: fzf-tab first; syntax-highlighting after
# widget-defining plugins; history-substring-search last.
if [[ -d ~/.local/share/zsh/fzf-tab/ ]]; then
  source ~/.local/share/zsh/fzf-tab/fzf-tab.plugin.zsh
fi
if [[ -d ~/.local/share/zsh/zsh-autosuggestions/ ]]; then
  source ~/.local/share/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
if [[ -d ~/.local/share/zsh/zsh-syntax-highlighting/ ]]; then
  source ~/.local/share/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
if [[ -d ~/.local/share/zsh/zsh-history-substring-search/ ]]; then
  source ~/.local/share/zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

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
alias cat='bat --paging=never'
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

# macOS uses the native Keychain agent (~/.ssh/config.d/defaults.conf), so this
# only runs on Linux where there's no launchd-managed agent. Every shell shares
# one agent on a fixed socket; keys load on first use via AddKeysToAgent, so
# startup never blocks on a passphrase. ssh-add exits 2 when no agent answers
# (e.g. a stale socket left over from before a reboot).
if [[ "$OSTYPE" == linux* && ! -S "${SSH_AUTH_SOCK:-}" ]]; then
  export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"
  ssh-add -l &> /dev/null
  if (( $? == 2 )); then
    rm -f "$SSH_AUTH_SOCK"
    ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null
  fi
fi

# Prompt
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# Zellij project launcher — attach if session exists, create with work layout if not
# Usage: dev              (use current dir as project)
#        dev <path>       (use a directory directly)
#        dev <project>    (resolve dir via zoxide)
dev() {
  if [[ -n "${ZELLIJ:-}" ]]; then
    echo "dev: already inside zellij — use Ctrl+g Ctrl+o w (session manager) to switch" >&2
    return 1
  fi

  local project dir checksum

  if [[ -d "${1:-.}" ]]; then
    dir="${1:-.}"
  else
    dir="$(zoxide query "$1" 2>/dev/null)" || {
      echo "dev: could not resolve '$1' — cd there once so zoxide learns it" >&2
      return 1
    }
  fi
  dir="$(cd -- "$dir" && pwd -P)" || return 1

  # Keep the name within 24 ASCII bytes for macOS's UNIX socket path limit.
  # ponytail: 32-bit path checksum; use a longer digest if session collisions arise.
  checksum="$(printf '%s' "$dir" | cksum)"
  project="${dir:t}"
  project="${project//[^a-zA-Z0-9_-]/-}"
  project="${project[1,13]}-${checksum%% *}"

  zellij attach "$project" 2>/dev/null || (cd "$dir" && zellij -s "$project" -n work)
}
_dev() {
  local -a dirs
  dirs=("${(@f)$(zoxide query -l 2>/dev/null)}")
  compadd -a dirs
}
compdef _dev dev

# Auto-connect Claude Code to this project's nvim IDE server (no /ide needed).
# claudecode.nvim writes ~/.claude/ide/<port>.lock containing its workspaceFolders.
# /dev/null keeps grep from reading stdin when no lockfiles exist.
# ponytail: exact $PWD match — cd to the project root, as the work layout does.
claude() {
  local lock=$(grep -ls "\"$PWD\"" ~/.claude/ide/*.lock(N) /dev/null | head -1)
  [[ -n $lock ]] && local -x ENABLE_IDE_INTEGRATION=true CLAUDE_CODE_SSE_PORT=${${lock:t}:r}
  command claude "$@"
}
