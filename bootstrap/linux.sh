#!/usr/bin/env bash
set -euo pipefail

info() { echo -e "\033[1;32m[ubuntu]\033[0m $*"; }

# Just enough to run install.sh's mise bootstrap; everything else comes from
# mise (packages/mise/.config/mise/config.toml).
info "🔧 Installing apt essentials..."
sudo apt update -y
sudo apt install -y git stow curl unzip build-essential zsh
sudo chsh -s "$(command -v zsh)" "$USER"
info "✅ Ubuntu setup complete"
