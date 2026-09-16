# dotfiles

Dotfiles managed declaratively using Nix and Home Manager.

## prerequisite

### Nix

Install Nix package manager (required):

```bash
# Install Nix with flakes support
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes (if not already enabled)
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### nix-darwin (macOS only)

On macOS the system layer is managed by [nix-darwin](https://github.com/nix-darwin/nix-darwin).
No manual install is needed: `./setup.sh` bootstraps it via `nix run nix-darwin`.
Homebrew is not required, but `/opt/homebrew/bin` is added to `PATH` if it exists.

If you use the Determinate Nix installer, add `nix.enable = false;` to
`nix/darwin/configuration.nix`, since that installer owns `/etc/nix`.

### Terminal

Install Wezterm

https://wezfurlong.org/wezterm/

On macOS, WezTerm is installed by Home Manager and reads `~/.wezterm.lua` directly,
so no extra step is required.

On WSL, WezTerm runs on the Windows host, so copy the config over:

```bash
cp ~/ghq/github.com/mikinovation/dotfiles/nix/programs/wezterm/.wezterm.lua /mnt/c/Users/[UserName]/
```

### Google Chrome (macOS only)

The `chrome-devtools` MCP server uses `pkgs.chromium` on Linux, which is not
available on macOS. Install Google Chrome to `/Applications` so the server can
find it.


## install

### Automatic Installation (Recommended)

Run the setup script, which will automatically detect the environment (NixOS or standalone) and deploy all configurations:

```bash
ghq get git@github.com:mikinovation/dotfiles.git
cd ~/ghq/github.com/mikinovation/dotfiles
./setup.sh
```

- NixOS (WSL): applies Home Manager as a module via `sudo nixos-rebuild switch`
- macOS: applies Home Manager as a module via `sudo darwin-rebuild switch`
- Other Linux: applies via standalone Home Manager

### Manual Installation

If you prefer to deploy manually using Home Manager:

```bash
# Clone the repository
ghq get git@github.com:mikinovation/dotfiles.git

# Setup nix.conf first
mkdir -p ~/.config/nix
ln -s ~/ghq/github.com/mikinovation/dotfiles/nix/nix.conf ~/.config/nix/nix.conf

# Deploy using Home Manager (standalone)
nix run home-manager/master -- switch --flake ~/ghq/github.com/mikinovation/dotfiles/nix#mikinovation

# Or for NixOS
sudo nixos-rebuild switch --flake ~/ghq/github.com/mikinovation/dotfiles/nix#nixos

# Or for macOS
sudo darwin-rebuild switch --flake ~/ghq/github.com/mikinovation/dotfiles/nix#mac
```

### Update Configuration

After making changes to your configuration files:

```bash
# Using Home Manager directly (standalone)
home-manager switch --flake ~/ghq/github.com/mikinovation/dotfiles/nix#mikinovation

# Or on macOS
sudo darwin-rebuild switch --flake ~/ghq/github.com/mikinovation/dotfiles/nix#mac

# Or re-run the setup script
cd ~/ghq/github.com/mikinovation/dotfiles
./setup.sh
```

### Setting up from a WSL release image

[Build WSL release image](.github/workflows/build-wsl-release.yml) builds a minimal NixOS-WSL image weekly (and on demand via `workflow_dispatch`) and publishes it as a GitHub Release asset. It embeds a copy of this repository, so a broken WSL install can be restored without network access to GitHub:

```powershell
# On Windows: download nixos.wsl from the latest release, then
wsl --import nixos <install-dir> nixos.wsl
wsl -d nixos
```

```bash
# Inside the imported distro
cd ~/ghq/github.com/mikinovation/dotfiles
./setup.sh
```

`./setup.sh` runs `nixos-rebuild switch` to rebuild the full Home Manager environment from the embedded repository.

## profiles

Each configuration is built with a `profile` (`full` or `light`), passed from `nix/flake.nix`
through `specialArgs` / `extraSpecialArgs`. Modules branch on it via `isFull = profile == "full"`.

| profile | used by | contents |
| --- | --- | --- |
| `full` | `darwinConfigurations.mac`, `homeConfigurations.mikinovation`, `nixosConfigurations.nixos-full` | everything |
| `light` | `nixosConfigurations.nixos` (WSL), `homeConfigurations.nixos` | text editing, documentation and agent work only |

`light` exists because the WSL box is only used for writing, design and requirements work -
it never runs or builds application code, and the WSL `ext4.vhdx` does not shrink on its own
once the Nix store has grown. It drops:

- Language toolchains: Rust, Ruby, Python (+ uv), and the Node dev tools (`pnpm`, `typescript`,
  `typescript-language-server`, `eslint`). `nodejs`, `yarn` and `prettier` stay.
- Language servers for those languages, in both Neovim and Claude Code
- `emacs`, `awscli2`, `terraform`, `_1password-cli`, PostgreSQL / SQLite / Prisma engines
- `playwright-driver.browsers` and the `chrome-devtools` MCP server (which pulls in `chromium`)
- `headroom` and its `ANTHROPIC_BASE_URL` proxy. It depends on `onnxruntime` and `transformers`,
  so its closure is large, and context compression only pays off on long coding sessions.
  Claude Code talks to `api.anthropic.com` directly instead, which keeps the 1M context window
  without `_CLAUDE_CODE_ASSUME_FIRST_PARTY_BASE_URL`.
- Docker, system fonts (WSL has no GUI and WezTerm runs on the Windows host), the offline
  NixOS manual, and `environment.defaultPackages`

`pandoc`, `typst` (with `tinymist`), `textlint`, `nodejs`, `prettier` and the whole Claude Code /
agent-skills setup are kept in both profiles. `programs.nix-ld` also stays enabled in both:
`nix/pkgs/claude-code.nix` ships a Node.js SEA binary that cannot be patchelf-ed and relies on it.

A C compiler, `gnumake` and `tree-sitter` are also kept in `light`, because markdown and typst
highlighting compile their tree-sitter parsers locally.

Neovim reads the profile from the `DOTFILES_PROFILE` environment variable (`nvim/profile.lua`)
and skips the test, debug, DB and language-specific plugins under `light`. When the variable is
unset - in CI, for example - it falls back to `full`.

To temporarily get the full environment on the WSL box:

```bash
sudo nixos-rebuild switch --flake ~/ghq/github.com/mikinovation/dotfiles/nix#nixos-full
```

The NixOS configuration also enables weekly `nix.gc` (`--delete-older-than 14d`) and
`nix.optimise.automatic`. Note that garbage collection alone does not return space to Windows:
the virtual disk has to be compacted afterwards, from an administrator PowerShell prompt.

```powershell
wsl --shutdown
wsl --manage nixos --set-sparse true
```

## lint, format, test

`nix run ./nix#lint` runs both luacheck and secretlint. secretlint requires node_modules, so run `npm ci` first:

```bash
npm ci
nix run ./nix#lint   # luacheck + secretlint
nix run ./nix#fmt    # stylua --check
nix run ./nix#test   # busted tests
```

To use the dev shell:

```bash
nix develop ./nix
```
