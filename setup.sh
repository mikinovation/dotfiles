#!/bin/bash

# dotfilesリポジトリのルートディレクトリへのパス
DOTFILES_DIR="$HOME/dotfiles"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
WEZTERM_CONFIG_DIR="$HOME"

# Neovimの設定ファイルをdotfilesリポジトリからシンボリックリンクとして配置
link_nvim_config() {
  echo "Linking neovim config..."
 
 # ディレクトリが存在しない場合は作成
  if [ ! -d "$NVIM_CONFIG_DIR" ]; then
    mkdir -p "$NVIM_CONFIG_DIR"
  fi
 
  for file in "$DOTFILES_DIR"/config/nvim/*; do
    ln -snfv "$file" "$NVIM_CONFIG_DIR/$(basename "$file")"
  done
 
  echo "Linking neovim done."
}

# Weztermの設定ファイルへのパス
link_wezterm_config() {
  echo "Linking wezterm config..."
 
 # ディレクトリが存在しない場合は作成
  if [ ! -d "$WEZTERM_CONFIG_DIR" ]; then
    mkdir -p "$WEZTERM_CONFIG_DIR"
  fi
 
  # .wezterm.luaをシンボリックリンクとして配置
  ln -snfv "$DOTFILES_DIR"/config/wezterm/.wezterm.lua "$HOME/.wezterm.lua"
 
  echo "Linking wezterm done."
}

# メインのスクリプト実行
main() {
  echo "Start setup dotfiles..."

  link_nvim_config
  echo "Linking neovim config done."

  link_wezterm_config
  echo "Linking wezterm config done."

  echo "Setup dotfiles done."
}

main
