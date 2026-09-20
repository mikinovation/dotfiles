# Product requirement documents

One file per change large enough that the reasoning will not fit in an issue.
Written before the work starts, updated while it is in progress, frozen when it
ships.

## When to write one

Write one when the change spans several pull requests, touches more than one
platform or profile, or has a completion condition that is not obvious from the
title. Everything smaller belongs in a GitHub issue — the feature request
template already covers description, motivation and proposed solution.

A PRD says what is being built and how we will know it is done. It does not say
which design was chosen; that is an ADR.

## Format

Copy [template.md](./template.md) to `NNNN-<kebab-case-title>.md`, where `NNNN`
is the next unused number.

```markdown
# NNNN — Title

- Status: Draft | Approved | Shipped | Dropped
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
- `Open questions` is emptied before the status becomes `Approved`. Anything
  still open at that point is a non-goal or a blocker.

## Lifecycle

`Draft` while being written, `Approved` once the scope is settled and the open
questions are resolved, `Shipped` when the last requirement is merged,
`Dropped` if abandoned.

A shipped or dropped document is not deleted and not rewritten. Update the
`Status` line and the `ADRs` list, and leave the rest as it was — the value is
in comparing what was planned against what happened.

## Index

<!-- Newest last. -->

_No documents yet._
