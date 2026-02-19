---
name: git-pr
description: Used when creating pull requests. Generates PR title and description based on branch changes.
disable-model-invocation: true
argument-hint: [base-branch]
allowed-tools: Bash(git *), Bash(gh *)
---

# Git Pull Request

Create a pull request against base branch `$ARGUMENTS`.

## Current state

- Current branch: !`git branch --show-current`
- Status: !`git status --short`
- Remote tracking: !`git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "No upstream set"`

## Steps

1. Determine the base branch from `$ARGUMENTS` (default: `main`)
2. Gather context by running in parallel:
   - `git log <base-branch>...HEAD --oneline` to see all commits
   - `git diff <base-branch>...HEAD --stat` to see changed files
   - `git diff <base-branch>...HEAD` for full diff
3. Check for PR template:
   - Look for `.github/PULL_REQUEST_TEMPLATE.md` or `.github/pull_request_template.md`
   - If found, use its structure for the PR body
4. Generate PR title and description:
   - Title: Short summary (under 70 chars), conventional commit format
   - Body: Fill in PR template if exists, otherwise use summary + test plan format
   - Match language (English/Japanese) from commit history
5. Push branch if needed:
   ```
   git push -u origin $(git branch --show-current)
   ```
6. Create PR using HEREDOC:
   ```
   gh pr create --draft --base <base-branch> --assignee mikinovation --title "title" --body "$(cat <<'EOF'
   <PR body here>
   EOF
   )"
   ```
7. Return the PR URL

## Rules

- Analyze ALL commits in the branch, not just the latest
- NEVER mention Claude Code or AI in PR content
- NEVER force push
- Always create as draft (`--draft`)
- If PR template exists, respect its structure and fill in all sections
- Always assign `mikinovation` as the PR assignee (`--assignee mikinovation`)
