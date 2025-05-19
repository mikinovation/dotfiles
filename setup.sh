#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
WEZTERM_CONFIG_DIR="$HOME"
SHELDON_CONFIG_DIR="$HOME/.config/sheldon"
ZSH_CONFIG_DIR="$HOME"
CLAUDE_DIR="$HOME/.claude"
GIT_CONFIG_DIR="$HOME/.config/git"

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

link_git_config() {
  if [ ! -d "$GIT_CONFIG_DIR" ]; then
    mkdir -p "$GIT_CONFIG_DIR"
  fi
 
  ln -snfv "$DOTFILES_DIR"/config/git/config "$GIT_CONFIG_DIR/config"
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
    echo "Error: npm is not installed or not in PATH"
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

  link_git_config
  echo "Linking git config done."

  copy_claude_config
  echo "Copying claude commands done."

  echo "Setup dotfiles done."
}

main
