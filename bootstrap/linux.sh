#!/usr/bin/env bash
set -euo pipefail

info() {
  echo -e "\033[1;32m[ubuntu]\033[0m $*"
}

# Everything else comes from mise (packages/mise/.config/mise/config.toml),
# installed by install.sh after stowing.
install_apt_packages() {
  info "Updating apt..."
  sudo apt update -y

  info "Installing apt packages..."
  sudo apt install -y \
    git \
    stow \
    curl \
    unzip \
    build-essential
}

install_mise() {
  if command -v mise &> /dev/null; then
    info "✓ mise already installed"
    return
  fi

  info "Installing mise..."
  sudo install -dm 755 /etc/apt/keyrings
  curl -fsSL https://mise.en.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.asc > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.en.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
  sudo apt update -y
  sudo apt install -y mise
}

main() {
  info "🔧 Starting Ubuntu bootstrap"
  install_apt_packages
  install_mise
  info "✅ Ubuntu setup complete"
}

main "$@"
