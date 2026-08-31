#!/usr/bin/env bash
set -euo pipefail

STOW_VERSION=2.4.1

info() {
  echo -e "\033[1;34m[macos]\033[0m $*"
}

# Stow is a Perl program, so this only substitutes paths — no compiler involved.
# It is the one CLI tool with no mise registry entry.
install_stow() {
  command -v stow &> /dev/null && { info "✓ stow already installed"; return; }
  info "Installing GNU Stow $STOW_VERSION..."
  local tmp; tmp="$(mktemp -d)"
  curl -fsSL "https://ftp.gnu.org/gnu/stow/stow-$STOW_VERSION.tar.gz" | tar xz -C "$tmp"
  (
    cd "$tmp/stow-$STOW_VERSION"
    ./configure --prefix="$HOME/.local" > /dev/null
    make install > /dev/null
  )
  rm -rf "$tmp"
}

# Load SSH keys into the login Keychain so the native agent unlocks them
# automatically (paired with ~/.ssh/config.d/defaults.conf). Skips keys already
# in the agent; prompts for a passphrase only the first time a key is added.
setup_ssh_keychain() {
  command -v ssh-add &> /dev/null || return 0
  local key fp
  for key in "$HOME/.ssh/auth" "$HOME/.ssh/sign"; do
    [ -f "$key" ] || continue
    fp="$(ssh-keygen -lf "$key" | awk '{print $2}')"
    if ssh-add -l 2>/dev/null | grep -q "$fp"; then
      info "✓ $(basename "$key") already loaded"
    else
      info "Adding $(basename "$key") to Keychain (may prompt for passphrase)..."
      ssh-add --apple-use-keychain "$key"
    fi
  done
}

main() {
  info "🔧 Starting macOS bootstrap"
  install_stow
  bash "$(dirname "$0")/casks.sh"
  setup_ssh_keychain
  info "✅ macOS setup complete"
}

main "$@"
