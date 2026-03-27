#!/bin/bash

DOTFILES_DIR="$HOME/ghq/github.com/mikinovation/dotfiles"
NIX_CONFIG_DIR="$HOME/.config/nix"

# Setup nix.conf (system-level configuration)
setup_nix_config() {
  if [ ! -d "$NIX_CONFIG_DIR" ]; then
    mkdir -p "$NIX_CONFIG_DIR"
  fi

  ln -snfv "$DOTFILES_DIR/config/nix/nix.conf" "$NIX_CONFIG_DIR/nix.conf"
  ln -snfv "$DOTFILES_DIR/config/nix/flake.nix" "$NIX_CONFIG_DIR/flake.nix"
  ln -snfv "$DOTFILES_DIR/config/nix/flake.lock" "$NIX_CONFIG_DIR/flake.lock"
}

# Deploy NixOS system configuration
deploy_nixos() {
  local hostname
  hostname="$(hostname)"
  echo "Deploying NixOS system configuration..."
  sudo nixos-rebuild switch --flake "$DOTFILES_DIR/config/nix#$hostname"
}

# Deploy configurations using Home Manager (standalone, for non-NixOS)
deploy_home_manager() {
  local username
  username="$(id -un)"
  echo "Deploying configurations with Home Manager..."
  nix run home-manager/master -- switch --flake "$DOTFILES_DIR/config/nix#$username"
}

main() {
  echo "Start setup dotfiles..."

  if ! command -v npm >/dev/null 2>&1; then
    echo "Warning: npm is not installed or not in PATH"
  fi

  # Setup Nix configuration first
  setup_nix_config
  echo "Nix config setup done."

  # Deploy configuration
  if [ -f /etc/nixos/hardware-configuration.nix ]; then
    # NixOS system: use nixos-rebuild (includes Home Manager as a module)
    deploy_nixos
    echo "NixOS deployment done."
  else
    # Non-NixOS: use standalone Home Manager
    deploy_home_manager
    echo "Home Manager deployment done."
  fi

  echo "Setup dotfiles done."
  echo ""
  echo "Please restart your shell or run 'source ~/.zshrc' to apply changes."
}

main
