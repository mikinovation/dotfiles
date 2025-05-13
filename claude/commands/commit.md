# Git Commit Instructions

This file provides guidance for creating effective Git commits in this repository.

## Commit Message Structure

- Use the conventional commits format: `<type>: <description>`
- Types include: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, etc.
- Write clear, concise descriptions in the imperative mood (e.g., "Add feature" not "Added feature")
- Keep the first line under 72 characters
- For complex changes, add a detailed body after a blank line

## Language Consistency

- Write code in the same language(s) used throughout the project
- Maintain consistent naming conventions, formatting, and idioms
- Follow existing patterns when extending functionality

## Commit Size and Scope

- Keep commits focused on a single logical change
- Break large changes into smaller, coherent commits
- Each commit should be independently reviewable and potentially revertible
- Consider these guidelines for splitting commits:
  - Separate refactoring from functional changes
  - Split feature implementation from tests
  - Divide large features along logical boundaries

## Authorship

- Do not include Claude or any AI assistant as a co-author
- Maintain clean commit history without AI attribution lines
- Take responsibility for all committed code regardless of assistance used

## Before Committing

- Run appropriate linting and formatting tools
- Ensure all tests pass
- Review the changes with `git diff` before finalizing
