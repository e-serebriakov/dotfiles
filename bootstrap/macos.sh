#!/usr/bin/env bash
set -euo pipefail

info() {
  echo -e "\033[1;34m[macos]\033[0m $*"
}

install_homebrew() {
  if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    info "✓ Homebrew already installed"
  fi
}

install_brewfile() {
  local brewfile="$(dirname "$0")/Brewfile"

  if [ ! -f "$brewfile" ]; then
    echo "[ERROR] Brewfile not found: $brewfile"
    exit 1
  fi

  info "Installing packages from Brewfile..."
  brew bundle install --file="$brewfile"
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
  install_homebrew
  install_brewfile
  setup_ssh_keychain
  info "✅ macOS setup complete"
}

main "$@"

