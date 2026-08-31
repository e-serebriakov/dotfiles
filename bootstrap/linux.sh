#!/usr/bin/env bash
set -euo pipefail

info() {
  echo -e "\033[1;32m[ubuntu]\033[0m $*"
}

# Just enough to run install.sh's mise bootstrap; everything else comes from
# mise (packages/mise/.config/mise/config.toml).
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

main() {
  info "🔧 Starting Ubuntu bootstrap"
  install_apt_packages
  info "✅ Ubuntu setup complete"
}

main "$@"
