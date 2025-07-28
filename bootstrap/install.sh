#!/usr/bin/env bash
set -euo pipefail

CONTEXT="${DOTFILES_CONTEXT:-personal}"
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$DOTFILES_DIR"

echo "▶ Installing dotfiles for platform: $PLATFORM, context: $CONTEXT"

# Always stow common
stow git zsh nvim starship tmux

# Platform-specific
if [[ "$PLATFORM" == "darwin" ]]; then
  stow aerospace
  bash bootstrap/macos.sh
elif [[ "$PLATFORM" == "linux" ]]; then
  bash bootstrap/linux.sh
fi

echo "✅ Done"

