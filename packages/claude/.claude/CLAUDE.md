# Global Instructions

## Git workflow with stacked branches

This user uses **Git Town** (`git town` CLI) to manage **stacked branches**.

### Key commands

- `git town sync` — sync all branches in the stack with their parents and the remote
- `git town propose` — create a PR for the current branch (sets the parent branch as the base)
- `git town ship` — merge a branch through the GitHub API and remove the branch
- `git town append <name>` — create a new branch stacked on top of the current one
- `git town prepend <name>` — insert a new branch between the current branch and its parent
- `git town set-parent` — re-parent a branch in the lineage
- `git town diff-parent` — show changes relative to the parent branch, not main

### Rules for Claude

- Use `git town` commands for branch management.
  Do not use `git merge`, `git rebase`, or `git push` directly.
- **When you create a new branch** that continues work from the current branch, use `git town append <name>`.
- **When you create an independent feature branch** from main, use `git town hack <name>`.
- **Before you propose a PR**, run `git town sync` to make sure that the stack is up to date.
- **When you view changes for a stacked branch**, use `git town diff-parent` or `git diff <parent-branch>..HEAD`.
  Do not use `git diff main`. It shows the full stack.
- **PR base branch**: use the parent branch in the stack.
  Use `main` only when it is the parent branch.
  `git town propose` selects the base automatically.
- **When the user asks you to ship or merge**, use `git town ship`.
  It merges through GitHub and removes the branch.
- **Branch names**: use the existing pattern in the repository.
  Use `git town config` to examine the branch relationships.

## Constraints

- Get permission before you add new pip or npm dependencies.
- Do not change CI/CD configuration.
- If you are not sure about a pattern, first find an existing example in the codebase.
