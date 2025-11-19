---
name: git-commit
description: Used when committing staged changes. Generates appropriate commit messages and confirms changes before creating commits.
---

# Git Commit

This skill is used to commit staged changes with appropriate commit messages.

## When to Use

- When the user requests to commit changes
- When `git commit` execution is needed
- When you need to review staged changes and generate a commit message

## Steps

1. **Review Changes**
   - Run `git status` to see changed files
   - Run `git diff --staged` to see detailed staged changes
   - Run `git log -5 --oneline` to see recent commit history

2. **Generate Commit Message**
   - Review recent commit history to determine the language (English or Japanese)
   - Create a single-line commit message based on the changes in the same language as recent commits
   - Use conventional commit prefixes (feat:, fix:, docs:, refactor:, test:, chore:, etc.)
   - Keep messages concise and clear (one line only, no description body)

3. **Execute Commit**
   - Commit with the generated message
   - Run `git status` after committing to verify the result

## Commit Message Guidelines

- **feat:** A new feature
- **fix:** A bug fix
- **docs:** Documentation only changes
- **style:** Changes that don't affect the meaning of the code (white-space, formatting, etc.)
- **refactor:** A code change that neither fixes a bug nor adds a feature
- **perf:** A code change that improves performance
- **test:** Adding missing tests or correcting existing tests
- **chore:** Changes to the build process or auxiliary tools and libraries

## Examples

### Example 1: Adding a New Feature

```bash
# Review changes
git status
git diff --staged

# Example commit message
git commit -m "feat: add user authentication feature"
```

### Example 2: Bug Fix

```bash
# Review changes
git status
git diff --staged

# Example commit message
git commit -m "fix: resolve login error when password is empty"
```

### Example 3: Refactoring

```bash
# Review changes
git status
git diff --staged

# Example commit message
git commit -m "refactor: extract authentication logic into separate module"
```

## Important Notes

- Always review changes before committing
- Check that no sensitive information (.env, credentials.json, etc.) is staged
- Focus commit messages on the "why" rather than the "what"
- If pre-commit hooks fail, fix the changes and commit again
- Do not include Claude Code references or co-author information in commit messages
- Use only single-line commit messages without description bodies
- Match the language (English or Japanese) of recent commit messages in the git log
