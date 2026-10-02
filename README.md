# dotfiles (moved)

This repository has moved to [`mikinovation/mikinovation` → `packages/dotfiles`](https://github.com/mikinovation/mikinovation/tree/main/packages/dotfiles) and is archived.

```bash
ghq get git@github.com:mikinovation/mikinovation.git
cd ~/ghq/github.com/mikinovation/mikinovation/packages/dotfiles
DOTFILES_PROFILE=full ./setup.sh
```

Existing checkouts at `~/ghq/github.com/mikinovation/dotfiles` are no longer updated. After switching, re-run `setup.sh` from the new location so that symlinks under `~/.config/nix` and the Claude Code hook paths point to the new directory.

The history up to the move (commit `8f01ba8`) remains in this repository.
