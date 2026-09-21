#!/usr/bin/env zsh
# Checks the claude() IDE auto-connect wrapper in packages/zsh/.zshrc.
# Run: zsh tests/claude_wrapper_test.zsh
set -u

# Load just the function, not the whole (side-effect heavy) zshrc.
eval "$(sed -n '/^claude() {/,/^}/p' ${0:a:h}/../packages/zsh/.zshrc)"

tmp=$(mktemp -d); tmp=$(cd $tmp && pwd -P); trap "rm -rf $tmp" EXIT
export HOME=$tmp PATH=$tmp/bin:$PATH
mkdir -p $tmp/.claude/ide $tmp/bin $tmp/other
cat > $tmp/bin/claude <<'STUB'
#!/bin/sh
printf 'port=%s ide=%s\n' "${CLAUDE_CODE_SSE_PORT:-none}" "${ENABLE_IDE_INTEGRATION:-none}"
STUB
chmod +x $tmp/bin/claude

check() {  # check <label> <expected> <actual>
  [[ $3 == $2 ]] && { print "ok   $1"; return }
  print "FAIL $1: expected '$2', got '$3'"; exit 1
}

# stdin carries a line that WOULD match, so a grep with no file operand
# (the bug this guards) consumes it and yields a garbage port instead of none.
cd $tmp
check "no lockfile -> unconnected, stdin untouched" "port=none ide=none" \
  "$(print -- "\"$tmp\"" | claude)"

print '{"workspaceFolders":["'$tmp'"]}' > $tmp/.claude/ide/4242.lock
check "workspace match -> connected" "port=4242 ide=true" "$(claude </dev/null)"

cd $tmp/other
check "different cwd -> unconnected" "port=none ide=none" "$(claude </dev/null)"

print "\nall checks passed"
