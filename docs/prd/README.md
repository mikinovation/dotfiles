# Product requirement documents

One file per planned change. Written before the work starts, updated while it
is in progress, frozen when it ships.

## When to write one

Write one for any change that is planned rather than incidental. There is no
size threshold and no issue-versus-document judgement to make: these documents
are kept current as the repository changes, so having one costs an edit rather
than a rewrite.

A PRD says what is being built and how we will know it is done. It does not say
which design was chosen; that is an ADR.

## Format

Copy [template.md](./template.md) to `NNNN-<kebab-case-title>.md`, where `NNNN`
is the next unused number.

```markdown
# NNNN — Title

- Status: Draft | Shipped | Dropped
- Date: YYYY-MM-DD
- ADRs: [NNNN — Title](../adr/NNNN-title.md) | none

## Problem
## Goals
## Non-goals
## Requirements
## Constraints
## Open questions
```

Rules that make the document worth keeping:

- `Problem` describes what is broken or missing today, with the cost of leaving
  it alone. No solution.
- `Goals` are verifiable. "Rebuild on a fresh WSL image completes without
  building chromium" is a goal; "faster setup" is not.
- `Non-goals` name what is deliberately out of scope, so the boundary survives
  the implementation.
- `Requirements` are numbered so pull requests can cite them.
- `Constraints` are the facts the design must obey, not preferences.
- `Open questions` is emptied before implementation starts. Anything still open
  at that point is a non-goal or a blocker.

## Lifecycle

`Draft` until the last requirement is merged, then `Shipped`, or `Dropped` if
abandoned. There is no approval state: the author and the approver are the same
person, so the only gate worth keeping is an empty `Open questions` before
implementation starts.

A shipped or dropped document is not deleted and not rewritten. Update the
`Status` line and the `ADRs` list, and leave the rest as it was — the value is
in comparing what was planned against what happened.

## Index

<!-- Newest last. -->

_No documents yet._
