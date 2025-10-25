#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
CLAUDE_DIR="$HOME/.claude"
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

copy_claude_config() {
  if [ ! -d "$CLAUDE_DIR/commands" ]; then
    mkdir -p "$CLAUDE_DIR/commands"
  fi

  for file in "$DOTFILES_DIR"/claude/commands/*; do
    cp -fv "$file" "$CLAUDE_DIR/commands/$(basename "$file")"
  done
}

main() {
  echo "Start setup dotfiles..."

  if ! command -v npm >/dev/null 2>&1; then
    echo "Warning: npm is not installed or not in PATH"
  fi

  # Setup Nix configuration first
  setup_nix_config
  echo "Nix config setup done."

  # Setup Claude-specific configurations
  copy_claude_config
  echo "Copying claude commands done."

  echo "Setup dotfiles done."
  echo ""
  echo "Please restart your shell or run 'source ~/.zshrc' to apply changes."
}

main
