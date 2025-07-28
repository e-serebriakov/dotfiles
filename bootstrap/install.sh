#!/usr/bin/env bash
set -euo pipefail

CONTEXT="${DOTFILES_CONTEXT:-personal}"
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$DOTFILES_DIR"

echo "▶ Installing dotfiles for platform: $PLATFORM, context: $CONTEXT"

# Platform-specific
if [[ "$PLATFORM" == "darwin" ]]; then
  bash bootstrap/macos.sh
  stow aerospace
elif [[ "$PLATFORM" == "linux" ]]; then
  bash bootstrap/linux.sh
fi

stow git zsh nvim starship tmux

echo "✅ Done"

