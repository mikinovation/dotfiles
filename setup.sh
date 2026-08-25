#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$HOME/ghq/github.com/mikinovation/dotfiles"
NIX_CONFIG_DIR="$HOME/.config/nix"

# Setup nix.conf (system-level configuration)
setup_nix_config() {
  if [ ! -d "$NIX_CONFIG_DIR" ]; then
    mkdir -p "$NIX_CONFIG_DIR"
  fi

  ln -snfv "$DOTFILES_DIR/nix/nix.conf" "$NIX_CONFIG_DIR/nix.conf"
  ln -snfv "$DOTFILES_DIR/nix/flake.nix" "$NIX_CONFIG_DIR/flake.nix"
  ln -snfv "$DOTFILES_DIR/nix/flake.lock" "$NIX_CONFIG_DIR/flake.lock"
}

# Deploy NixOS system configuration
deploy_nixos() {
  local hostname
  hostname="$(hostname)"
  echo "Deploying NixOS system configuration..."
  sudo nixos-rebuild switch --flake "$DOTFILES_DIR/nix#$hostname"
}

# Deploy nix-darwin system configuration (macOS)
deploy_darwin() {
  echo "Deploying nix-darwin system configuration..."
  if command -v darwin-rebuild >/dev/null 2>&1; then
    sudo darwin-rebuild switch --flake "$DOTFILES_DIR/nix#mac"
  else
    sudo nix run nix-darwin -- switch --flake "$DOTFILES_DIR/nix#mac"
  fi
}

# Deploy configurations using Home Manager (standalone, for non-NixOS)
deploy_home_manager() {
  local username
  username="$(id -un)"
  echo "Deploying configurations with Home Manager..."
  nix run home-manager/master -- switch --flake "$DOTFILES_DIR/nix#$username"
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
  if [ "$(uname -s)" = "Darwin" ]; then
    # macOS: use darwin-rebuild (includes Home Manager as a module).
    # hostname can resolve to "<name>.local" on macOS, so the flake attribute
    # is fixed to "mac" instead of being derived from the hostname.
    deploy_darwin
    echo "nix-darwin deployment done."
  elif [ -f /etc/NIXOS ]; then
    # NixOS system (including NixOS-WSL, which has no hardware-configuration.nix):
    # use nixos-rebuild (includes Home Manager as a module)
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
