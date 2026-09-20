# Product requirement documents

One file per planned change. Written before the work starts and kept current
afterwards, so it describes what the repository does today rather than what was
once intended.

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

`Shipped` does not mean finished. A shipped document is maintained: when the
behaviour it describes changes, the body changes with it, so `Goals` and
`Requirements` always read as statements about the current repository. The
record of what was originally planned is in the git history of the file, not in
the file itself.

A dropped document is left as it was, with the reason for dropping it in
`Open questions`. Nothing in `docs/prd/` is deleted.

## Index

<!-- Newest last. -->

_No documents yet._
