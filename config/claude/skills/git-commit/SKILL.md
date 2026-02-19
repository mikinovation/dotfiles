---
name: git-commit
description: Used when committing staged changes. Generates appropriate commit messages and confirms changes before creating commits.
disable-model-invocation: true
allowed-tools: Bash(git *)
---

# Git Commit

Commit staged changes with appropriate commit messages.

## Current state

- Status: !`git status --short`
- Staged changes: !`git diff --staged --stat`
- Recent commits: !`git log -5 --oneline`

## Steps

1. Analyze the staged changes shown above
2. If no changes are staged, ask the user what to stage
3. Generate a commit message (must be a single line, no line breaks):
   - Use conventional commit format: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, etc.
   - Match language (English/Japanese) from recent commit history above
   - Keep it short and concise, focus on "why" rather than "what"
4. Execute the commit:
   ```
   git commit -m "<commit message here>"
   ```
   - Commit message is always a single line (no multi-line messages)
5. Verify with `git status`

## Rules

- NEVER amend existing commits unless explicitly asked
- NEVER use `--no-verify` flag
- NEVER run `git push` - only commit locally
- Stage specific files by name, never use `git add -A` or `git add .`
- If pre-commit hook fails, fix the issue and create a NEW commit
