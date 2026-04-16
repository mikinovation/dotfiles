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
cp ~/ghq/github.com/mikinovation/dotfiles/config/wezterm/.wezterm.lua /mnt/c/Users/[UserName]/
```

### node2nix

To update npm packages managed by node2nix:

```bash
# Navigate to the node2nix directory
cd ~/ghq/github.com/mikinovation/dotfiles/config/node2nix

# Edit node-packages.json to add/update packages

# Run node2nix to generate Nix expressions
nix-shell -p nodePackages.node2nix --command "node2nix -i ./node-packages.json -o node-packages.nix"
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
ln -s ~/ghq/github.com/mikinovation/dotfiles/config/nix/nix.conf ~/.config/nix/nix.conf

# Deploy using Home Manager (standalone)
nix run home-manager/master -- switch --flake ~/ghq/github.com/mikinovation/dotfiles/config/nix#mikinovation

# Or for NixOS
sudo nixos-rebuild switch --flake ~/ghq/github.com/mikinovation/dotfiles/config/nix#nixos
```

### Update Configuration

After making changes to your configuration files:

```bash
# Using Home Manager directly (standalone)
home-manager switch --flake ~/ghq/github.com/mikinovation/dotfiles/config/nix#mikinovation

# Or re-run the setup script
cd ~/ghq/github.com/mikinovation/dotfiles
./setup.sh
```

## lint, format, test

`nix run ./config/nix#lint` runs both luacheck and secretlint. secretlint requires node_modules, so run `npm ci` first:

```bash
npm ci
nix run ./config/nix#lint   # luacheck + secretlint
nix run ./config/nix#fmt    # stylua --check
nix run ./config/nix#test   # busted tests
```

To use the dev shell:

```bash
nix develop ./config/nix
```
