#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CONTEXT="${DOTFILES_CONTEXT:-personal}"
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="$DOTFILES_DIR/packages"
TARGET="$HOME"

cd "$DOTFILES_DIR"

echo "▶ Installing dotfiles for platform: $PLATFORM, context: $CONTEXT"

# Platform-specific
if [[ "$PLATFORM" == "darwin" ]]; then
  bash bootstrap/macos.sh
elif [[ "$PLATFORM" == "linux" ]]; then
  bash bootstrap/linux.sh
fi

# Zsh plugins
ZSH_PLUGIN_DIR="$HOME/.local/share/zsh"
mkdir -p "$ZSH_PLUGIN_DIR"
while IFS='=' read -r name url; do
  if [[ ! -d "$ZSH_PLUGIN_DIR/$name" ]]; then
    echo "  Installing zsh plugin: $name"
    git clone --depth 1 "$url" "$ZSH_PLUGIN_DIR/$name"
  fi
done <<'PLUGINS'
fzf-tab=https://github.com/Aloxaf/fzf-tab
zsh-syntax-highlighting=https://github.com/zsh-users/zsh-syntax-highlighting
zsh-history-substring-search=https://github.com/zsh-users/zsh-history-substring-search
zsh-autosuggestions=https://github.com/zsh-users/zsh-autosuggestions
PLUGINS

# Build package list using shell globbing (portable on macOS)
PKGS=()
for dir in "$STOW_DIR"/*/ ; do
  # skip if glob didn't match anything
  [[ -d "$dir" ]] || continue
  pkg="$(basename "$dir")"
  PKGS+=("$pkg")
done

# Dry-run: ./bootstrap/install.sh -n
if [[ "${1:-}" == "-n" || "${1:-}" == "--dry-run" ]]; then
  stow -n -v -d "$STOW_DIR" -t "$TARGET" "${PKGS[@]}"
else
  # --adopt moves conflicting real files into packages/, then we restore
  # only packages/ so uncommitted changes elsewhere (Brewfile etc.) are safe.
  stow --adopt -R -v -d "$STOW_DIR" -t "$TARGET" "${PKGS[@]}"
  git -C "$DOTFILES_DIR" diff --name-only packages/ | \
    xargs -I{} git -C "$DOTFILES_DIR" checkout -- {}
fi

echo "✅ Done"

