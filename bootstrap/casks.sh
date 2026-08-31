#!/usr/bin/env bash
# Installs the GUI apps and pkg-based tools that mise cannot manage.
set -euo pipefail

info() { echo -e "\033[1;35m[apps]\033[0m $*"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Some repos (AeroSpace) ship only pre-releases, so /releases/latest is empty.
# Reading the releases list and filtering keeps both cases on one code path.
gh_asset() { # $1=owner/repo  $2=asset regex
  curl -fsSL "https://api.github.com/repos/$1/releases?per_page=5" \
    | grep -o '"browser_download_url": "[^"]*"' | cut -d'"' -f4 \
    | grep -E "$2" | head -1
}

mount_dmg() { # $1=dmg path -> echoes mount point
  hdiutil attach -nobrowse -readonly "$1" \
    | awk '/\/Volumes\//{print substr($0, index($0, "/Volumes/"))}' | head -1
}

app_from_zip() { # $1=name  $2=url
  [ -d "/Applications/$1.app" ] && { info "✓ $1 already installed"; return; }
  info "Installing $1..."
  curl -fsSL "$2" -o "$TMP/$1.zip"
  unzip -q "$TMP/$1.zip" -d "$TMP/$1"
  cp -R "$TMP/$1"/*.app /Applications/
}

app_from_dmg() { # $1=name  $2=url
  [ -d "/Applications/$1.app" ] && { info "✓ $1 already installed"; return; }
  info "Installing $1..."
  curl -fsSL "$2" -o "$TMP/$1.dmg"
  local mnt; mnt="$(mount_dmg "$TMP/$1.dmg")"
  cp -R "$mnt"/*.app /Applications/
  hdiutil detach "$mnt" -quiet
}

# Karabiner registers a driver extension, so its pkg must actually run.
pkg_from_dmg() { # $1=name  $2=url  $3=marker path
  [ -e "$3" ] && { info "✓ $1 already installed"; return; }
  info "Installing $1 (requires sudo)..."
  curl -fsSL "$2" -o "$TMP/$1.dmg"
  local mnt; mnt="$(mount_dmg "$TMP/$1.dmg")"
  sudo installer -pkg "$(find "$mnt" -maxdepth 1 -name '*.pkg' | head -1)" -target /
  hdiutil detach "$mnt" -quiet
}

install_pkg() { # $1=name  $2=url  $3=marker path
  [ -e "$3" ] && { info "✓ $1 already installed"; return; }
  info "Installing $1 (requires sudo)..."
  curl -fsSL "$2" -o "$TMP/$1.pkg"
  sudo installer -pkg "$TMP/$1.pkg" -target /
}

install_font() {
  if compgen -G "$HOME/Library/Fonts/JetBrainsMono*" > /dev/null; then
    info "✓ JetBrains Mono Nerd Font already installed"; return
  fi
  info "Installing JetBrains Mono Nerd Font..."
  curl -fsSL "$(gh_asset ryanoasis/nerd-fonts 'JetBrainsMono\.zip$')" -o "$TMP/font.zip"
  unzip -q "$TMP/font.zip" -d "$TMP/font"
  mkdir -p "$HOME/Library/Fonts"
  find "$TMP/font" -name '*.ttf' -exec cp {} "$HOME/Library/Fonts/" \;
}

main() {
  info "🖥  Installing apps"
  app_from_zip WezTerm   "$(gh_asset wez/wezterm 'WezTerm-macos-.*\.zip$')"
  app_from_zip AeroSpace "$(gh_asset nikitabobko/AeroSpace 'AeroSpace-v.*\.zip$')"
  app_from_zip Secretive "$(gh_asset maxgoedjen/secretive 'Secretive\.zip$')"
  app_from_dmg Raycast   "https://www.raycast.com/download"
  app_from_dmg OrbStack  "https://orbstack.dev/download/stable/latest/arm64"
  pkg_from_dmg Karabiner-Elements \
    "$(gh_asset pqrs-org/Karabiner-Elements 'Karabiner-Elements-.*\.dmg$')" \
    /Applications/Karabiner-Elements.app
  install_pkg mosh "$(gh_asset mobile-shell/mosh 'mosh-.*\.pkg$')" /usr/local/bin/mosh
  install_font
  info "✅ Apps installed"
}

main "$@"
