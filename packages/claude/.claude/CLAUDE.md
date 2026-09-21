# Global Instructions

## Git Workflow — Git Town & Stacked Branches

This user works with **stacked branches** managed by **Git Town** (`git town` CLI).

### Key commands

- `git town sync` — sync all branches in the stack with their parents and the remote
- `git town propose` — create a PR for the current branch (auto-sets base to parent branch)
- `git town ship` — merge a branch via GitHub API and clean up
- `git town append <name>` — create a new branch stacked on top of the current one
- `git town prepend <name>` — insert a new branch between the current branch and its parent
- `git town set-parent` — re-parent a branch in the lineage
- `git town diff-parent` — show changes relative to the parent branch, not main

### Rules for Claude

- **Never use raw `git merge`, `git rebase`, or `git push`** for branch management — use `git town` commands instead.
- **When creating a new branch** that continues work from the current branch, use `git town append <name>`.
- **When creating an independent feature branch** from main, use `git town hack <name>`.
- **Before proposing a PR**, run `git town sync` to ensure the stack is up to date.
- **When viewing changes for a stacked branch**, use `git town diff-parent` or `git diff <parent-branch>..HEAD` — not `git diff main`, which would show the entire stack.
- **PR base branch** is always the parent in the stack, not main (unless the branch is a direct child of main). `git town propose` handles this automatically.
- **When asked to ship/merge**, use `git town ship` — it handles the GitHub merge and cleans up the branch.
- **Branch naming**: follow the existing pattern in the repo (check `git town config` for lineage context).

## Constraints

- Never add new pip/npm dependencies without asking first
- Never modify database migrations directly — generate them with manage.py
- Never modify CI/CD configuration
- When unsure about a pattern, find an existing example in the codebase first
