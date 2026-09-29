#!/usr/bin/env bash
set -euo pipefail

info() {
  echo -e "\033[1;34m[macos]\033[0m $*"
}

install_homebrew() {
  command -v brew &> /dev/null && { info "✓ homebrew already installed"; return; }
  info "Installing Homebrew (needs admin)..."
  # Cache sudo credentials: NONINTERACTIVE skips RETURN and checks sudo with -n.
  # That check fails without cached credentials. Karabiner-Elements can reuse them.
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Store key passphrases in Keychain for automatic use with ~/.ssh/config.d/defaults.conf.
# Skip keys already in the agent. Request a passphrase when first adding a key.
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
  install_homebrew
  # Add the Apple Silicon Homebrew location to PATH; the installer does not change it.
  eval "$(/opt/homebrew/bin/brew shellenv)"
  info "Installing apps from Brewfile (Karabiner-Elements prompts for sudo)..."
  brew bundle --no-upgrade --file "$(dirname "$0")/Brewfile"
  setup_ssh_keychain
  info "✅ macOS setup complete"
}

main "$@"
