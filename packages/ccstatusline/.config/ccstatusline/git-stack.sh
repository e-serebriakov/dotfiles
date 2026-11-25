#!/bin/sh
# Print the current branch with its Git Town parents: main › rex-preview › claude-mods.
# The custom-command widget in settings.json shows it in place of the git-branch widget.
# Git Town keeps each branch's parent in git config as git-town-branch.<branch>.parent.
# One git config call for all parents: a call per parent is too slow for the widget's timeout.
branch=$(git branch --show-current 2>/dev/null) || exit 0
git config --get-regexp '^git-town-branch\..*\.parent$' | awk -v branch="$branch" '
  { gsub(/^git-town-branch\.|\.parent$/, "", $1); parent[$1] = $2 }
  END { stack = branch; while (branch in parent) { branch = parent[branch]; stack = branch " › " stack }; print stack }'
