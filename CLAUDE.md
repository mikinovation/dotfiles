# CLAUDE.md

## Development Workflow

### Post-Task Verification

After completing ANY code changes, you MUST run the following verification steps in order:

```bash
sh ./scripts/lint.sh && sh ./scripts/format.sh && busted .
```
