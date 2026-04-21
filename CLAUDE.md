# CLAUDE.md

## Development Workflow

### Post-Task Verification

After completing ANY code changes, you MUST run the following verification steps in order:

```bash
nix run ./nix#lint && nix run ./nix#fmt && nix run ./nix#test
```

Note: `nix run ./nix#lint` runs luacheck only (secretlint requires `npm ci` first).
Each command can also be run individually:

```bash
nix run ./nix#fmt   # stylua --check
nix run ./nix#test  # busted tests
nix run ./nix#lint  # luacheck (+ secretlint if node_modules present)
```
