#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
NIX_CONFIG_DIR="$HOME/.config/nix"

is_nixos() {
  [ -f /etc/NIXOS ]
}

# Setup nix.conf (system-level configuration)
# Only needed for non-NixOS environments
setup_nix_config() {
  if is_nixos; then
    echo "NixOS detected: skipping nix.conf symlink (managed by NixOS)"
    return
  fi

  if [ ! -d "$NIX_CONFIG_DIR" ]; then
    mkdir -p "$NIX_CONFIG_DIR"
  fi

  # Only link nix.conf, not the entire directory
  # (home-manager will manage flake.nix and home.nix)
  ln -snfv "$DOTFILES_DIR/config/nix/nix.conf" "$NIX_CONFIG_DIR/nix.conf"
}

# Deploy configurations using Home Manager (Ubuntu WSL)
deploy_home_manager() {
  echo "Deploying configurations with Home Manager..."
  nix run home-manager/master -- switch --flake ~/dotfiles/config/nix#mikinovation
}

# Deploy configurations using nixos-rebuild (NixOS-WSL)
deploy_nixos() {
  echo "Deploying NixOS configuration..."
  sudo nixos-rebuild switch --flake ~/dotfiles/config/nix#nixos
}

main() {
  echo "Start setup dotfiles..."

  if ! is_nixos && ! command -v npm >/dev/null 2>&1; then
    echo "Warning: npm is not installed or not in PATH"
  fi

  # Setup Nix configuration first
  setup_nix_config
  echo "Nix config setup done."

  # Deploy based on environment
  if is_nixos; then
    deploy_nixos
    echo "NixOS deployment done."
  else
    deploy_home_manager
    echo "Home Manager deployment done."
  fi

  echo "Setup dotfiles done."
  echo ""
  echo "Please restart your shell or run 'source ~/.zshrc' to apply changes."
}

main
