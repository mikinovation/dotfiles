---
name: git-commit
description: Used when committing staged changes. Generates appropriate commit messages and confirms changes before creating commits.
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
3. Generate a single-line commit message:
   - Use conventional commit format: `feat:`, `fix:`, `docs:`, `refactor:`, `test:`, `chore:`, etc.
   - Match language (English/Japanese) from recent commit history above
   - Focus on "why" rather than "what"
4. Execute the commit using HEREDOC format:
   ```
   git commit -m "$(cat <<'EOF'
   <commit message here>
   EOF
   )"
   ```
5. Verify with `git status`

## Rules

- NEVER amend existing commits unless explicitly asked
- NEVER use `--no-verify` flag
- NEVER run `git push` - only commit locally
- Stage specific files by name, never use `git add -A` or `git add .`
- If pre-commit hook fails, fix the issue and create a NEW commit
