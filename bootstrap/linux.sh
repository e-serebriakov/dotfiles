#!/usr/bin/env bash
set -euo pipefail

info() { echo -e "\033[1;32m[ubuntu]\033[0m $*"; }

# Install setup requirements and zsh. mise installs the remaining tools
# from packages/mise/.config/mise/config.toml.
info "🔧 Setup installs the necessary apt packages."
sudo apt update -y
sudo apt install -y git stow curl unzip build-essential zsh
sudo chsh -s "$(command -v zsh)" "$USER"

# Rex has no Linux client. Rex for Mac connects to this server over SSH.
# The install script adds the Rex apt repository, so apt upgrades Rex with the other packages.
if ! command -v rex &> /dev/null; then
  info "🔧 Setup installs the Rex server."
  curl -fsSL https://pkgs.superlogical.com/rex/install.sh | sh
fi
# Start the server at boot and keep it running while you are logged out. No sudo is necessary.
rex server install
info "✅ Ubuntu setup is completed."
