#!/usr/bin/env bash
# Installs the GUI apps and pkg-based tools that mise cannot manage.
set -euo pipefail

info() { echo -e "\033[1;35m[apps]\033[0m $*"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Several functions below install CLIs here, and `find -exec install` fails
# silently (find still exits 0), so create it once up front.
mkdir -p "$HOME/.local/bin"

# Some repos (AeroSpace) ship only pre-releases, so /releases/latest is empty.
# Reading the releases list and filtering keeps both cases on one code path.
# The six calls share GitHub's 60/hr unauthenticated budget; GITHUB_TOKEN raises
# it to 5000 and is optional.
gh_asset() { # $1=owner/repo  $2=asset regex
  local json url
  json="$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$1/releases?per_page=5")" || :
  # One awk, not a pipeline: a filter that stops at the first match SIGPIPEs
  # whatever is upstream, and pipefail reports that as failure even though the
  # URL was found — wezterm and nerd-fonts have JSON large enough to hit it.
  url="$(awk -v re="$2" '/"browser_download_url":/ {
    split($0, a, "\""); if (a[4] ~ re) { print a[4]; exit }
  }' <<< "$json")"
  # Covers both a failed request and a release with no matching asset; without
  # it the caller curls an empty URL and reports only that the URL is malformed.
  [ -n "$url" ] || { info "❌ no asset matching $2 in $1 (rate limited? set GITHUB_TOKEN)"; return 1; }
  printf '%s\n' "$url"
}

# Captured for the same reason, and so a failed attach cannot pass an empty
# mount point to the caller's `cp`.
mount_dmg() { # $1=dmg path -> echoes mount point
  local out
  out="$(hdiutil attach -nobrowse -readonly "$1")" || return
  awk '/\/Volumes\//{print substr($0, index($0, "/Volumes/")); exit}' <<< "$out"
}

app_from_zip() { # $1=name  $2=url
  [ -d "/Applications/$1.app" ] && { info "✓ $1 already installed"; return; }
  info "Installing $1..."
  curl -fsSL "$2" -o "$TMP/$1.zip"
  unzip -q "$TMP/$1.zip" -d "$TMP/$1"
  cp -R "$TMP/$1"/*.app /Applications/
  # AeroSpace ships its CLI beside the .app inside the archive; no-op for the rest.
  find "$TMP/$1" -type f -path '*/bin/*' -perm -u+x \
    -exec install -m 755 {} "$HOME/.local/bin/" \;
}

# The casks used to drop these into /opt/homebrew/bin. They live inside the app
# bundles, so linking them keeps the commands working without Homebrew.
link_app_clis() {
  local src
  for src in \
    /Applications/WezTerm.app/Contents/MacOS/wezterm \
    /Applications/WezTerm.app/Contents/MacOS/wezterm-gui \
    /Applications/WezTerm.app/Contents/MacOS/wezterm-mux-server \
    /Applications/WezTerm.app/Contents/MacOS/strip-ansi-escapes \
    /Applications/OrbStack.app/Contents/MacOS/bin/orb \
    /Applications/OrbStack.app/Contents/MacOS/bin/orbctl \
    "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
  do
    if [ -e "$src" ]; then
      ln -sfn "$src" "$HOME/.local/bin/$(basename "$src")"
    fi
  done
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

# mosh's pkg holds three binaries that link only against /usr/lib, so unpacking
# it into ~/.local/bin works and keeps sudo out of the picture.
install_mosh() {
  [ -x "$HOME/.local/bin/mosh" ] && { info "✓ mosh already installed"; return; }
  info "Installing mosh..."
  curl -fsSL "$(gh_asset mobile-shell/mosh 'mosh-.*\.pkg$')" -o "$TMP/mosh.pkg"
  pkgutil --expand-full "$TMP/mosh.pkg" "$TMP/mosh"
  find "$TMP/mosh" -type f -perm -u+x -name 'mosh*' \
    -exec install -m 755 {} "$HOME/.local/bin/" \;
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
  install_mosh
  install_font
  link_app_clis
  info "✅ Apps installed"
}

main "$@"
