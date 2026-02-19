#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
NIX_CONFIG_DIR="$HOME/.config/nix"

# Setup nix.conf (system-level configuration)
setup_nix_config() {
  if [ ! -d "$NIX_CONFIG_DIR" ]; then
    mkdir -p "$NIX_CONFIG_DIR"
  fi

  # Only link nix.conf, not the entire directory
  # (home-manager will manage flake.nix and home.nix)
  ln -snfv "$DOTFILES_DIR/config/nix/nix.conf" "$NIX_CONFIG_DIR/nix.conf"
}

# Deploy configurations using Home Manager
deploy_home_manager() {
  echo "Deploying configurations with Home Manager..."
  nix run home-manager/master -- switch --flake ~/dotfiles/config/nix#mikinovation
}

main() {
  echo "Start setup dotfiles..."

  if ! command -v npm >/dev/null 2>&1; then
    echo "Warning: npm is not installed or not in PATH"
  fi

  # Setup Nix configuration first
  setup_nix_config
  echo "Nix config setup done."

  # Deploy dotfiles using Home Manager
  deploy_home_manager
  echo "Home Manager deployment done."

  echo "Setup dotfiles done."
  echo ""
  echo "Please restart your shell or run 'source ~/.zshrc' to apply changes."
}

main
