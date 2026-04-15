# CLAUDE.md

## Development Workflow

### Post-Task Verification

After completing ANY code changes, you MUST run the following verification steps in order:

```bash
nix run ./config/nix#lint && nix run ./config/nix#fmt && nix run ./config/nix#test
```

Note: `nix run ./config/nix#lint` runs luacheck only (secretlint requires `npm ci` first).
Each command can also be run individually:

```bash
nix run ./config/nix#fmt   # stylua --check
nix run ./config/nix#test  # busted tests
nix run ./config/nix#lint  # luacheck (+ secretlint if node_modules present)
```
