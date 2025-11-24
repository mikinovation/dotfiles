---
name: git-pr
description: Used when creating pull requests. Generates PR title and description based on branch changes.
---

# Git Pull Request

Create a pull request with appropriate title and description.

## Steps

1. Use the base branch specified in the command arguments
2. Check for PR template in `.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE.md`
3. Run `git status`, `git diff <base-branch>...HEAD`, and `git log <base-branch>..HEAD --oneline`
4. Analyze all commits and changes from base branch
5. Generate PR title and description:
   - Title: Single-line summary using conventional commit format
   - Description: If template exists, fill it in with appropriate content. Otherwise, include summary, test plan, and changes overview
6. Match language (English/Japanese) from commit history
7. Push branch if needed: `git push -u origin <branch>`
8. Create PR with base branch: `gh pr create --base <base-branch> --title "title" --body "description"`
9. Return PR URL

## Notes

- No Claude Code references
- Analyze ALL commits in the branch, not just the latest
- Include base branch comparison (e.g., `git diff main...HEAD`)
- Push with `-u` flag if branch not yet pushed
- PR template locations to check: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`
- If template exists, respect its structure and fill in all sections appropriately
