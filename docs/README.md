# docs

Why this repository is shaped the way it is.

| Location | Contents |
| --- | --- |
| `README.md` (root) | How to install and use the dotfiles. Written for someone setting up a machine. |
| `CLAUDE.md` | Instructions for coding agents. Not prose documentation. |
| `docs/prd/` | What is going to be built, and how we will know it is done. Written before the work. |
| `docs/adr/` | Why a structural choice was made, and what it costs. Written when the choice is made. |

A change that is only visible when installing belongs in the root `README.md`,
not here.

These are plain Markdown files rendered by github.com. There is no site, no
front matter and no build step.

## Numbering

Both directories use a four-digit sequential number, independent of each other:
`docs/prd/0001-<slug>.md`, `docs/adr/0001-<slug>.md`. Numbers are never reused,
including for records that were dropped.

## Cross-references

A PRD lists the ADRs that came out of it. An ADR links back to the PRD that
forced the decision, if there was one. Keep both ends in sync when adding a
record.
