---
name: git-commit
description: Used when committing staged changes. Generates appropriate commit messages and confirms changes before creating commits.
---

# Git Commit

Commit staged changes with appropriate commit messages.

## Steps

1. Run `git status`, `git diff --staged`, and `git log -5 --oneline`
2. Generate single-line commit message using conventional commit format (feat:, fix:, docs:, refactor:, test:, chore:, etc.)
3. Match language (English/Japanese) from recent commit history
4. Execute `git commit -m "message"`
5. Verify with `git status`
