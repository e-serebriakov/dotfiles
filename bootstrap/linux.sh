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
    fzf \
    ripgrep \
    build-essential \
    software-properties-common \
    neovim \
    bat \
    fd-find \
    jq \
    zoxide
}

install_helix() {
  if is_installed hx; then
    info "✓ helix already installed"
  else
    info "Adding Helix PPA and installing helix..."
    sudo add-apt-repository -y ppa:maveonair/helix-editor
    sudo apt install -y helix
  fi
}

install_mise() {
  if is_installed mise; then
    info "✓ mise already installed"
  else
    info "Installing mise..."
    sudo install -dm 755 /etc/apt/keyrings
    curl -fsSL https://mise.en.dev/gpg-key.pub | sudo tee /etc/apt/keyrings/mise-archive-keyring.asc > /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/mise-archive-keyring.asc] https://mise.en.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list
    sudo apt update -y
    sudo apt install -y mise
  fi
}

install_zellij() {
  if is_installed zellij; then
    info "✓ zellij already installed"
  else
    info "Installing zellij..."
    curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/zellij-$(uname -m)-unknown-linux-musl.tar.gz" \
      | tar -xz -C /tmp
    sudo install /tmp/zellij /usr/local/bin/
    rm -f /tmp/zellij
  fi
}

install_gh() {
  if is_installed gh; then
    info "✓ gh already installed"
  else
    info "Installing GitHub CLI..."
    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update -y
    sudo apt install -y gh
  fi
}

install_git_delta() {
  if is_installed delta; then
    info "✓ git-delta already installed"
  else
    info "Installing git-delta..."
    local version arch tmp
    version=$(curl -fsSL "https://api.github.com/repos/dandavison/delta/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    arch=$(dpkg --print-architecture)
    tmp=$(mktemp -d)
    curl -fsSL "https://github.com/dandavison/delta/releases/download/${version}/git-delta_${version}_${arch}.deb" -o "${tmp}/git-delta.deb"
    sudo dpkg -i "${tmp}/git-delta.deb"
    rm -rf "$tmp"
  fi
}

install_eza() {
  if is_installed eza; then
    info "✓ eza already installed"
  else
    info "Installing eza..."
    local version arch
    version=$(curl -fsSL "https://api.github.com/repos/eza-community/eza/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    arch=$(uname -m)
    curl -fsSL "https://github.com/eza-community/eza/releases/download/${version}/eza_${arch}-unknown-linux-gnu.tar.gz" \
      | tar -xz -C /tmp
    sudo install /tmp/eza /usr/local/bin/
    rm -f /tmp/eza
  fi
}

install_git_town() {
  if is_installed git-town; then
    info "✓ git-town already installed"
  else
    info "Installing git-town..."
    local version tmp
    version=$(curl -fsSL "https://api.github.com/repos/git-town/git-town/releases/latest" | grep -Po '"tag_name": "\K[^"]*')
    tmp=$(mktemp -d)
    curl -fsSL "https://github.com/git-town/git-town/releases/download/${version}/git-town_linux_arm_64.deb" -o "${tmp}/git-town.deb"
    sudo dpkg -i "${tmp}/git-town.deb"
    rm -rf "$tmp"
  fi
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
  install_mise
  install_zellij
  install_gh
  install_git_delta
  install_eza
  install_git_town
  install_helix
  info "✅ Ubuntu setup complete"
}

main "$@"

