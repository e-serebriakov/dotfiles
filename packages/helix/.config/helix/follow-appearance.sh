#!/bin/sh
# Link Helix's "baked" theme to the light or dark variant that matches the system, then reload open Helix windows.
# launchd runs this script when the macOS preferences change. install.sh runs it once on every platform.
themes="$HOME/.config/helix/themes"
mode=light
# AppleInterfaceStyle exists only in dark mode. On Linux, defaults is missing, so Helix stays light.
defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark && mode=dark
[ "$(readlink "$themes/baked.toml")" = "baked-$mode.toml" ] && exit 0
ln -sf "baked-$mode.toml" "$themes/baked.toml"
# Helix reloads its config, and so its theme, on SIGUSR1. No open Helix is not an error.
pkill -USR1 -x hx || true
