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
  # If you want to adopt existing real files into the repo, uncomment:
  # stow --adopt -v -d "$STOW_DIR" -t "$TARGET" "${PKGS[@]}"

  # Idempotent linking
  stow -R -v -d "$STOW_DIR" -t "$TARGET" "${PKGS[@]}"
fi

echo "✅ Done"

