#!/usr/bin/env bash
set -euo pipefail

info() {
  echo -e "\033[1;34m[macos]\033[0m $*"
}

install_homebrew() {
  command -v brew &> /dev/null && { info "✓ homebrew already installed"; return; }
  info "Installing Homebrew (needs admin — Privileges.app if this is a managed Mac)..."
  # NONINTERACTIVE skips the RETURN prompt but also makes the installer's sudo
  # check use -n, which fails with no cached timestamp. Warm it here; the
  # Karabiner-Elements cask reuses it later in the bundle.
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
  # The installer leaves PATH alone; on Apple Silicon brew lands here.
  eval "$(/opt/homebrew/bin/brew shellenv)"
  info "Installing apps from Brewfile (Karabiner-Elements prompts for sudo)..."
  brew bundle --file "$(dirname "$0")/Brewfile"
  setup_ssh_keychain
  info "✅ macOS setup complete"
}

main "$@"
