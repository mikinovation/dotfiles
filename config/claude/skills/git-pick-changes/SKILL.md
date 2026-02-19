---
name: git-pick-changes
description: From a source branch, identify changed files and let user select which changes to apply as a patch to the current branch.
disable-model-invocation: true
argument-hint: <source-branch>
allowed-tools: Bash(git *)
---

# Git Pick Changes

Selectively apply file-level changes from a source branch to the current branch using patch application.

## Current state

- Current branch: !`git branch --show-current`
- Status: !`git status --short`
- Recent commits: !`git log -5 --oneline`

## Steps

1. Get the source branch from `$ARGUMENTS`
   - If `$ARGUMENTS` is empty, ask the user which branch to pick changes from
   - Verify the branch exists: `git rev-parse --verify $ARGUMENTS`
   - If the branch does not exist, inform the user and stop

2. Check for uncommitted changes:
   - If `git status --short` shows changes, warn the user:
     ```
     Warning: You have uncommitted changes. Applying patches may cause conflicts.
     Continue anyway?
     ```
   - Wait for user confirmation before proceeding

3. List changed files between current branch and source branch:
   ```
   git diff HEAD...$ARGUMENTS --name-status
   ```
   - The three-dot diff (`...`) compares against the common ancestor, showing only changes unique to the source branch

4. Present changes to the user, grouped by directory:
   ```
   ## Changed files on <source-branch> (N files)

   ### src/components/
   - [M] Button.tsx
   - [A] Modal.tsx

   ### src/utils/
   - [M] helpers.ts
   - [D] deprecated.ts

   ---
   Which files do you want to apply? (specify file numbers, paths, or "all")
   ```
   - `[A]` = Added, `[M]` = Modified, `[D]` = Deleted, `[R]` = Renamed

5. Wait for user to select files

6. Generate a patch for the selected files:
   ```
   git diff HEAD...$ARGUMENTS -- <file1> <file2> ...
   ```

7. Apply the patch:
   ```
   git apply <patch>
   ```
   - If `git apply` fails, retry with `--3way` flag for three-way merge fallback:
     ```
     git apply --3way <patch>
     ```
   - If both fail, show the error and suggest manual resolution

8. Show the result:
   - `git status --short`
   - `git diff --stat`
   - Inform the user that changes are left unstaged for review

## Rules

- NEVER apply changes without user selecting files first
- NEVER auto-commit applied changes - leave them unstaged for user review
- NEVER use `--no-verify` flag
- NEVER use `git push` or `git push --force`
- NEVER amend existing commits
- If the source branch is the same as the current branch, inform the user and stop
