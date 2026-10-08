#!/usr/bin/env bash
set -euo pipefail

info() {
  echo -e "\033[1;34m[macos]\033[0m $*"
}

install_homebrew() {
  command -v brew &> /dev/null && { info "✓ Homebrew is installed"; return; }
  info "Setup installs Homebrew (administrator access is necessary)."
  # Cache sudo credentials: NONINTERACTIVE skips RETURN and checks sudo with -n.
  # That check fails without cached credentials. Karabiner-Elements can reuse them.
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Store key passphrases in Keychain. SSH uses them automatically with ~/.ssh/config.d/defaults.conf.
# Skip keys that the agent contains. Request a passphrase when the script first adds a key.
setup_ssh_keychain() {
  command -v ssh-add &> /dev/null || return 0
  local key fp
  for key in "$HOME/.ssh/auth" "$HOME/.ssh/sign"; do
    [ -f "$key" ] || continue
    fp="$(ssh-keygen -lf "$key" | awk '{print $2}')"
    if ssh-add -l 2>/dev/null | grep -q "$fp"; then
      info "✓ $(basename "$key") is loaded"
    else
      info "Setup adds $(basename "$key") to Keychain. It can request a passphrase."
      ssh-add --apple-use-keychain "$key"
    fi
  done
}

main() {
  info "🔧 macOS setup starts."
  install_homebrew
  # Add the Apple Silicon Homebrew location to PATH. The installer does not change it.
  eval "$(/opt/homebrew/bin/brew shellenv)"
  info "Setup installs applications from Brewfile. Karabiner-Elements requests sudo access."
  brew bundle --no-upgrade --file "$(dirname "$0")/Brewfile"
  setup_ssh_keychain
  info "✅ macOS setup is completed."
}

main "$@"
