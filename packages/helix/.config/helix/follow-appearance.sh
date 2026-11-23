#!/bin/sh
# Link Helix's "baked" theme to the light or dark variant that matches the system, then reload open Helix windows.
# Also switch running Zellij sessions to the matching theme.
# launchd runs this script when the macOS preferences change. install.sh runs it once on every platform.
themes="$HOME/.config/helix/themes"
mode=light
# AppleInterfaceStyle exists only in dark mode. On Linux, defaults is missing, so Helix stays light.
defaults read -g AppleInterfaceStyle 2>/dev/null | grep -q Dark && mode=dark

# TODO: drop this Zellij block, and --explicit-theme-hue in dev (.zshrc), once WezTerm ships mode 2031 / DSR 996
# (wezterm#6454). Zellij then follows the terminal through theme_light and theme_dark alone.
# Until then, Zellij hears no report and falls back to theme_dark. Each action pins the session to $mode.
# launchd's PATH lacks the mise shims. Exited sessions reject actions, so ignore failures.
PATH="$PATH:$HOME/.local/share/mise/shims"
for s in $(zellij list-sessions -s -n 2>/dev/null); do
  zellij -s "$s" action "set-$mode-theme" >/dev/null 2>&1
done

[ "$(readlink "$themes/baked.toml")" = "baked-$mode.toml" ] && exit 0
ln -sf "baked-$mode.toml" "$themes/baked.toml"
# Helix reloads its config, and so its theme, on SIGUSR1. No open Helix is not an error.
pkill -USR1 -x hx || true
