# Architecture decision records

One file per decision, numbered sequentially, never rewritten after acceptance.
If a decision is reversed, write a new record and mark the old one superseded.

## When to write one

Write a record when the reasoning would otherwise be lost:

- an obvious alternative was rejected
- the choice trades one cost for another
- the decision will look wrong to someone who does not know the constraint

Do not write one for decisions the code makes self-evident, or for changes with
no alternative worth naming.

## Format

Copy [template.md](./template.md) to `NNNN-<kebab-case-title>.md`, where `NNNN`
is the next unused number.

```markdown
# NNNN — Title

- Status: Proposed | Accepted | Superseded by [NNNN](./NNNN-title.md)
- Date: YYYY-MM-DD
- PRD: [NNNN — Title](../prd/NNNN-title.md) | none

## Context
## Decision
## Consequences
## Alternatives considered
```

Rules that make the record worth keeping:

- `Context` states constraints, not narrative. What forced a decision.
- `Decision` is present tense and specific enough to contradict.
- `Consequences` includes the downsides. A record listing only benefits is
  worthless later.
- `Alternatives considered` is never empty. If nothing was rejected, the
  decision did not need a record.

## Lifecycle

`Proposed` while under discussion, `Accepted` once merged. After acceptance the
file is frozen except for the `Status` line. Reversing a decision means a new
record plus `Superseded by [NNNN]` on the old one.

## Index

<!-- Newest last. -->

_No records yet._
