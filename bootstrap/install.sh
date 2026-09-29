#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CONTEXT="${DOTFILES_CONTEXT:-personal}"
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOW_DIR="$DOTFILES_DIR/packages"
TARGET="$HOME"

# mise installs here and brew puts stow on PATH; bash does not read .zshenv,
# which sets both for zsh.
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

echo "▶ Installing dotfiles for platform: $PLATFORM, context: $CONTEXT"

# Both platforms get their tools from mise, so it is installed here rather than
# twice in the platform scripts. Runs after them because Linux needs apt's curl.
install_mise() {
  if command -v mise &> /dev/null; then
    echo "  ✓ mise already installed"
    return
  fi
  echo "▶ Installing mise..."
  curl -fsSL https://mise.run | sh
}

# Skipped on a dry run: these install apps and packages, and brew bundle
# prompts for sudo. Only the stow step below is simulated.
if [[ -z "$DRY_RUN" ]]; then
  if [[ "$PLATFORM" == "darwin" ]]; then
    bash bootstrap/macos.sh
  elif [[ "$PLATFORM" == "linux" ]]; then
    bash bootstrap/linux.sh
  fi
  install_mise
else
  echo "  (dry run: skipping platform bootstrap)"
fi

# Restore an exact revision without overwriting local plugin edits.
install_zsh_plugin() {
  local name="$1" url="$2" revision="$3" dir="$ZSH_PLUGIN_DIR/$1"
  if [[ ! -d "$dir" ]]; then
    git init --quiet "$dir"
  fi
  if [[ -n "$(git -C "$dir" status --porcelain)" ]]; then
    echo "✗ $name has local changes; save them before restoring plugins" >&2
    return 1
  fi
  [[ "$(git -C "$dir" rev-parse --verify HEAD 2>/dev/null || :)" == "$revision" ]] && return 0
  if ! git -C "$dir" cat-file -e "$revision^{commit}" 2>/dev/null; then
    git -C "$dir" fetch --depth 1 "$url" "$revision"
  fi
  git -C "$dir" checkout --quiet --detach "$revision"
}

# Zsh plugins — change these revisions deliberately; setup never pulls latest.
if [[ -n "$DRY_RUN" ]]; then
  echo "  (dry run: skipping zsh plugins)"
else
  ZSH_PLUGIN_DIR="$HOME/.local/share/zsh"
  mkdir -p "$ZSH_PLUGIN_DIR"
  while IFS=' ' read -r name url revision; do
    echo "  Restoring zsh plugin: $name"
    install_zsh_plugin "$name" "$url" "$revision"
  done <<'PLUGINS'
fzf-tab https://github.com/Aloxaf/fzf-tab 24105b15714bfec37989ed5c5b6e60f572253019
zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting 2fc57d63067c18b1100ecdbf684fa5baf49459d1
zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search 14c8d2e0ffaee98f2df9850b19944f32546fdea5
zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5
PLUGINS
fi

# Build package list using shell globbing (portable on macOS)
PKGS=()
NON_CLAUDE_PKGS=()
for dir in "$STOW_DIR"/*/ ; do
  # skip if glob didn't match anything
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
  # Theme artifacts are gitignored build outputs, regenerated here before stowing.
  # Neither a missing babashka nor a bad token file should block re-stowing every
  # other package; both just mean the tools fall back to their default colours.
  # Read the repo's config + adjacent lockfile before they are stowed. Install
  # only Babashka here; the remaining tools are installed after stow.
  if ! command -v mise &> /dev/null; then
    echo "⚠ mise not found — skipping theme generation" >&2
  else
    echo "▶ Generating theme files from design tokens..."
    if ! (
      export MISE_GLOBAL_CONFIG_FILE="$STOW_DIR/mise/.config/mise/config.toml"
      cd "$DOTFILES_DIR/theme" &&
        mise install --locked babashka &&
        bb_dir="$(mise where babashka)" &&
        "$bb_dir/bin/bb" -m generate
    ); then
      echo "⚠ theme generation failed — stowing anyway; theme falls back to defaults" >&2
    fi
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
      [[ "$pkg" != "claude" && "$rel" == .claude/* ]] && continue
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
  stow -R -v --ignore='(^|/)\.claude($|/)' -d "$STOW_DIR" -t "$TARGET" "${NON_CLAUDE_PKGS[@]}"
  stow -R -v -d "$STOW_DIR" -t "$TARGET" claude

  # gitconfig points gpg.ssh.allowedSignersFile here; runs after stow so
  # user.email is readable.
  if [[ -f "$HOME/.ssh/sign.pub" && ! -f "$HOME/.ssh/allowed_signers" ]]; then
    echo "  creating ~/.ssh/allowed_signers"
    echo "$(git config --global user.email) $(cat "$HOME/.ssh/sign.pub")" > "$HOME/.ssh/allowed_signers"
  fi
fi

# Install tools declared in packages/mise/.config/mise/config.toml
if [[ -n "$DRY_RUN" ]]; then
  echo "  (dry run: skipping mise tools)"
elif command -v mise &> /dev/null; then
  echo "▶ Installing mise tools..."
  # Resolving 30 tools at once trips GitHub's unauthenticated rate limit, and
  # the vfox plugin fetches fail first. Fewer parallel jobs avoids it; an
  # immediate retry does not, since the limit takes minutes to clear.
  if ! MISE_JOBS="${MISE_JOBS:-4}" mise install --locked; then
    echo "✗ Setup incomplete: some tools failed to install. Re-run 'mise install --locked' after resolving the error above." >&2
    exit 1
  fi
else
  echo "✗ Setup incomplete: mise is not on PATH. Re-run ./bootstrap/install.sh after installing mise." >&2
  exit 1
fi

echo "✅ Done"
