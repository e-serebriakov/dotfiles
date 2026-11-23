#!/bin/sh
# Report the state of Claude Code to Rex. Claude Code hooks run this script. Usage: status.sh STATE [KIND]
# Rex shows the state on the tab and in the session list. See https://www.superlogical.com/rex/docs/build/program-status.
# Hooks run without a controlling terminal, so write the sequence to the terminal of Claude Code, the parent process.
[ -n "${REX_SESSION:-}" ] || exit 0
t=$(ps -o tty= -p "$PPID" | tr -d ' ')
case "$t" in '' | '?' | '??') exit 0 ;; esac
printf '\033]7501;state=%s:app=claude-code%s\033\\' "$1" "${2:+:kind=$2}" 2>/dev/null >"/dev/$t"
exit 0
