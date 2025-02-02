#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
WEZTERM_CONFIG_DIR="$HOME"
SHELDON_CONFIG_DIR="$HOME/.config/sheldon"
ZSH_CONFIG_DIR="$HOME"

link_nvim_config() {
  if [ ! -d "$NVIM_CONFIG_DIR" ]; then
    mkdir -p "$NVIM_CONFIG_DIR"
  fi
 
  for file in "$DOTFILES_DIR"/config/nvim/*; do
    ln -snfv "$file" "$NVIM_CONFIG_DIR/$(basename "$file")"
  done
}

link_wezterm_config() {
  if [ ! -d "$WEZTERM_CONFIG_DIR" ]; then
    mkdir -p "$WEZTERM_CONFIG_DIR"
  fi
 
  ln -snfv "$DOTFILES_DIR"/config/wezterm/.wezterm.lua "$HOME/.wezterm.lua"
}

link_sheldon_config() {
  if [ ! -d "$SHELDON_CONFIG_DIR" ]; then
    mkdir -p "$SHELDON_CONFIG_DIR"
  fi
 
  ln -snfv "$DOTFILES_DIR"/config/sheldon/plugins.toml "$HOME/.config/sheldon/plugins.toml"
}

link_zsh_config() {
  if [ ! -d "$ZSH_CONFIG_DIR" ]; then
    mkdir -p "$ZSH_CONFIG_DIR"
  fi

  ln -snfv "$DOTFILES_DIR"/config/zsh/.zshrc "$HOME/.zshrc"
  ln -snfv "$DOTFILES_DIR"/config/zsh/.p10k.zsh "$HOME/.p10k.zsh"
}

main() {
  echo "Start setup dotfiles..."

  echo "Update nix environment..."
  if ! nix run .#update; then
    echo "Error: Failed to update nix environment"
    exit 1
  fi
  echo "Nix environment update complete."

  if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm is not installed or not in PATH"
    exit 1
  fi

  echo "Install npm packages..."

  if ! npm install -g typescript typescript-language-server @vue/language-server @vue/typescript-plugin tailwindcss-language-server eslint_d stylelint; then
    echo "Error: Failed to install npm packages"
    exit 1
  fi

  link_nvim_config
  echo "Linking neovim config done."

  link_wezterm_config
  echo "Linking wezterm config done."

  link_sheldon_config
  echo "Linking sheldon config done."

  link_zsh_config
  echo "Linking zsh config done."

  echo "Setup dotfiles done."
}

main
