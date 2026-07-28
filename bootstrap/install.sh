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
  # Theme artifacts are gitignored build outputs, regenerated here before stowing.
  if ! command -v python3 &> /dev/null; then
    echo "❌ python3 is required to generate theme files (theme/generate.py)." >&2
    exit 1
  fi
  echo "▶ Generating theme files from design tokens..."
  # A token typo must not block re-stowing every other package.
  if ! python3 "$DOTFILES_DIR/theme/generate.py"; then
    echo "⚠ theme generation failed — stowing anyway; theme falls back to defaults" >&2
  fi

  # Without this, a ~/.config symlinked into a foreign repo would make $tgt resolve
  # into that repo, and the backup loop would relocate that repo's file.
  foreign_ancestor() {
    local dir; dir="$(dirname "$1")"
    while [[ "$dir" != "$TARGET" && "$dir" != "/" && "$dir" != "." ]]; do
      if [[ -L "$dir" ]]; then
        local real; real="$(cd "$dir" 2>/dev/null && pwd -P)" || return 0
        [[ "$real" == "$STOW_DIR"/* ]] || return 0
      fi
      dir="$(dirname "$dir")"
    done
    return 1
  }

  # Replaces `stow --adopt` + `git checkout -- packages/`, which reverted ALL
  # uncommitted changes under packages/, not just the adopted conflicts.
  BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
  for pkg in "${PKGS[@]}"; do
    while IFS= read -r -d '' src; do
      rel="${src#"$STOW_DIR/$pkg/"}"
      tgt="$TARGET/$rel"
      # The `-ef` guard skips our own stow symlinks (they resolve back to $src),
      # so only genuine conflicts get backed up and `stow -R` won't abort.
      if [[ -e "$tgt" || -L "$tgt" ]] && ! [[ "$tgt" -ef "$src" ]]; then
        if foreign_ancestor "$tgt"; then
          echo "  ⚠ skipping $rel (target path crosses a foreign symlinked dir)" >&2
          continue
        fi
        echo "  backing up existing $rel"
        mkdir -p "$BACKUP/$(dirname "$rel")"
        mv "$tgt" "$BACKUP/$rel"
      fi
    done < <(find "$STOW_DIR/$pkg" -type f -print0)
  done
  [[ -d "$BACKUP" ]] && echo "  (pre-existing files backed up to $BACKUP)"
  stow -R -v -d "$STOW_DIR" -t "$TARGET" "${PKGS[@]}"
fi

# Install tools declared in packages/mise/.config/mise/config.toml
if command -v mise &> /dev/null; then
  echo "▶ Installing mise tools..."
  mise install
fi

echo "✅ Done"

