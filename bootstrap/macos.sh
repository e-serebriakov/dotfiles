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

main() {
  info "🔧 Starting macOS bootstrap"
  install_homebrew
  install_brewfile
  info "✅ macOS setup complete"
}

main "$@"

