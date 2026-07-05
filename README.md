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

### Terminal

Install Wezterm

https://wezfurlong.org/wezterm/

On Windows, copy the WezTerm config to the host OS:

```bash
cp ~/ghq/github.com/mikinovation/dotfiles/nix/programs/wezterm/.wezterm.lua /mnt/c/Users/[UserName]/
```


## install

### Automatic Installation (Recommended)

Run the setup script, which will automatically detect the environment (NixOS or standalone) and deploy all configurations:

```bash
ghq get git@github.com:mikinovation/dotfiles.git
cd ~/ghq/github.com/mikinovation/dotfiles
./setup.sh
```

- NixOS (WSL): applies Home Manager as a module via `sudo nixos-rebuild switch`
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
```

### Update Configuration

After making changes to your configuration files:

```bash
# Using Home Manager directly (standalone)
home-manager switch --flake ~/ghq/github.com/mikinovation/dotfiles/nix#mikinovation

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
