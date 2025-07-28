#!/usr/bin/env bash
set -euo pipefail

info() {
  echo -e "\033[1;32m[ubuntu]\033[0m $*"
}

is_installed() {
  command -v "$1" &> /dev/null
}

update_apt() {
  info "Updating apt..."
  sudo apt update -y
}

install_apt_packages() {
  info "Installing apt packages..."

  sudo apt install -y \
    git \
    stow \
    curl \
    unzip \
    tmux \
    fzf \
    ripgrep \
    build-essential \
    software-properties-common \
    neovim
}

install_starship() {
  if is_installed starship; then
    info "✓ starship already installed"
  else
    info "Installing starship..."
    curl -fsSL https://starship.rs/install.sh | bash -s -- -y
  fi
}

main() {
  info "🔧 Starting Ubuntu bootstrap"
  update_apt
  install_apt_packages
  install_starship
  info "✅ Ubuntu setup complete"
}

main "$@"

