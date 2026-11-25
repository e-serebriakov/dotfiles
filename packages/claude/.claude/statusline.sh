#!/bin/sh
# The Claude Code status line: model · context · Git Town stack · changed lines.
# Claude Code passes the session as JSON on stdin: https://code.claude.com/docs/en/statusline

# The context is what the last request sent: its input tokens, cache writes, and cache reads.
jq -j '(.context_window.current_usage // {} | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)) as $n
  | "\u001b[36m\(.model.display_name // "?")\u001b[0m · \u001b[90mCtx: \(if $n >= 1000 then "\($n / 100 | round / 10)k" else $n end)\u001b[0m"'

# The current branch with its Git Town parents: main › rex-preview › claude-mods.
# Git Town keeps each parent in git config as git-town-branch.<branch>.parent. One git config call reads them all.
# The stack stops at 20 parents, so a cycle in the config cannot hang the status line.
branch=$(git branch --show-current 2>/dev/null)
[ -n "$branch" ] || exit 0
stack=$(git config --get-regexp '^git-town-branch\..*\.parent$' | awk -v branch="$branch" '
  { gsub(/^git-town-branch\.|\.parent$/, "", $1); parent[$1] = $2 }
  END { stack = branch; while (branch in parent && n++ < 20) { branch = parent[branch]; stack = branch " › " stack }; print stack }')
# Staged and unstaged lines. A binary file counts as 0.
changes=$(git diff HEAD --numstat 2>/dev/null | awk '{ added += $1; deleted += $2 } END { printf "(+%d,-%d)", added, deleted }')
printf ' · \033[35m%s\033[0m · \033[33m%s\033[0m' "$stack" "$changes"
