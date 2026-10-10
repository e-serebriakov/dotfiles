#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CONTEXT="${DOTFILES_CONTEXT:-personal}"
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="$DOTFILES_DIR/packages"
TARGET="$HOME"

# Add mise and Homebrew to PATH. Bash does not read the zsh settings in .zshenv.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"

cd "$DOTFILES_DIR"

DRY_RUN=""
case "${1:-}" in
  "") ;;
  -n|--dry-run) DRY_RUN=1 ;;
  -h|--help)
    echo "Usage: $0 [-n|--dry-run]"
    exit 0 ;;
  *)
    echo "Unknown option: $1 (see --help)" >&2
    exit 2 ;;
esac

echo "▶ Setup installs dotfiles for platform: $PLATFORM, context: $CONTEXT"

# Install mise once for macOS and Ubuntu, after the platform scripts install curl.
install_mise() {
  if command -v mise &> /dev/null; then
    echo "  ✓ mise is installed"
    return
  fi
  echo "▶ Setup installs mise."
  curl -fsSL https://mise.run | sh
}

# Skip installation during a dry run. Only simulate the Stow operations below.
if [[ -z "$DRY_RUN" ]]; then
  if [[ "$PLATFORM" == "darwin" ]]; then
    bash bootstrap/macos.sh
  elif [[ "$PLATFORM" == "linux" ]]; then
    bash bootstrap/linux.sh
  fi
  install_mise
else
  echo "  (dry run: setup skips platform installation)"
fi

# Restore the specified revision. Keep local plugin changes.
install_zsh_plugin() {
  local name="$1" url="$2" revision="$3" dir="$ZSH_PLUGIN_DIR/$1"
  if [[ ! -d "$dir" ]]; then
    git init --quiet "$dir"
  fi
  if [[ -n "$(git -C "$dir" status --porcelain)" ]]; then
    echo "✗ $name has local changes. Save them before you restore the plugins." >&2
    return 1
  fi
  [[ "$(git -C "$dir" rev-parse --verify HEAD 2>/dev/null || :)" == "$revision" ]] && return 0
  if ! git -C "$dir" cat-file -e "$revision^{commit}" 2>/dev/null; then
    git -C "$dir" fetch --depth 1 "$url" "$revision"
  fi
  git -C "$dir" checkout --quiet --detach "$revision"
}

# Update these plugin revisions manually. Setup restores only the listed commits.
if [[ -n "$DRY_RUN" ]]; then
  echo "  (dry run: setup skips zsh plugins)"
else
  ZSH_PLUGIN_DIR="$HOME/.local/share/zsh"
  mkdir -p "$ZSH_PLUGIN_DIR"
  while IFS=' ' read -r name url revision; do
    echo "  Setup restores zsh plugin: $name"
    install_zsh_plugin "$name" "$url" "$revision"
  done <<'PLUGINS'
fzf-tab https://github.com/Aloxaf/fzf-tab 24105b15714bfec37989ed5c5b6e60f572253019
zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting 2fc57d63067c18b1100ecdbf684fa5baf49459d1
zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search 14c8d2e0ffaee98f2df9850b19944f32546fdea5
zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
PLUGINS
fi

# Use shell globbing to list packages. This also operates on macOS.
PKGS=()
NON_CLAUDE_PKGS=()
for dir in "$STOW_DIR"/*/ ; do
  # Skip unmatched patterns.
  [[ -d "$dir" ]] || continue
  pkg="$(basename "$dir")"
  PKGS+=("$pkg")
  [[ "$pkg" == "claude" ]] || NON_CLAUDE_PKGS+=("$pkg")
done

# Dry-run: ./bootstrap/install.sh -n
if [[ -n "$DRY_RUN" ]]; then
  stow -n -v --ignore='(^|/)\.claude($|/)' -d "$STOW_DIR" -t "$TARGET" "${NON_CLAUDE_PKGS[@]}"
  stow -n -v -d "$STOW_DIR" -t "$TARGET" claude
else
  # Generate theme files before Stow creates links. Git ignores the output files.
  # Continue if Babashka is unavailable or generation fails.
  # theme/mise.toml and theme/mise.lock fix the Babashka version, so generation does not need the Stow links.
  # Install only Babashka here. Install the other tools after Stow creates the links.
  if ! command -v mise &> /dev/null; then
    echo "⚠ mise is not available. Setup skips theme generation." >&2
  else
    echo "▶ Setup generates theme files from design tokens."
    if ! (
      cd "$DOTFILES_DIR/theme" &&
        mise install --locked babashka &&
        "$(mise which bb)" -m generate
    ); then
      echo "⚠ Theme generation failed. Setup continues with Stow. Tools use their default colors." >&2
    fi
  fi

  # Keep backups in this repository. Do not move files through links to directories in a different repository.
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

  # Back up conflicting files. Keep uncommitted package changes.
  # Do not use stow --adopt followed by git checkout -- packages/.
  BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
  for pkg in "${PKGS[@]}"; do
    while IFS= read -r -d '' src; do
      rel="${src#"$STOW_DIR/$pkg/"}"
      [[ "$pkg" != "claude" && "$rel" == .claude/* ]] && continue
      tgt="$TARGET/$rel"
      # -ef keeps links to $src. Move conflicting targets before stow -R.
      if [[ -e "$tgt" || -L "$tgt" ]] && ! [[ "$tgt" -ef "$src" ]]; then
        if foreign_ancestor "$tgt"; then
          echo "  ⚠ Setup skips $rel. The target path crosses a symbolic link to a directory outside packages/." >&2
          continue
        fi
        echo "  Setup makes a backup of $rel."
        mkdir -p "$BACKUP/$(dirname "$rel")"
        mv "$tgt" "$BACKUP/$rel"
      fi
    done < <(find "$STOW_DIR/$pkg" -type f -print0)
  done
  [[ -d "$BACKUP" ]] && echo "  (setup moved conflicting files to $BACKUP)"
  stow -R -v --ignore='(^|/)\.claude($|/)' -d "$STOW_DIR" -t "$TARGET" "${NON_CLAUDE_PKGS[@]}"
  stow -R -v -d "$STOW_DIR" -t "$TARGET" claude

  # Create gpg.ssh.allowedSignersFile after Stow makes user.email available.
  if [[ -f "$HOME/.ssh/sign.pub" && ! -f "$HOME/.ssh/allowed_signers" ]]; then
    echo "  Setup creates ~/.ssh/allowed_signers."
    echo "$(git config --global user.email) $(cat "$HOME/.ssh/sign.pub")" > "$HOME/.ssh/allowed_signers"
  fi
fi

# Install tools declared in packages/mise/.config/mise/config.toml
if [[ -n "$DRY_RUN" ]]; then
  echo "  (dry run: setup skips mise tools)"
elif command -v mise &> /dev/null; then
  echo "▶ Setup installs mise tools."
  # Limit concurrent jobs to reduce errors caused by GitHub rate limits, especially for vfox.
  # An immediate retry does not help. The limit takes minutes to clear.
  if ! MISE_JOBS="${MISE_JOBS:-4}" mise install --locked; then
    echo "✗ Some tools failed to install. Correct the error. Then run 'mise install --locked' again." >&2
    exit 1
  fi
else
  echo "✗ mise is not on PATH. Install mise. Then run ./bootstrap/install.sh again." >&2
  exit 1
fi

echo "✅ Done"
