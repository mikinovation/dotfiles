#!/bin/bash

# dotfilesリポジトリのルートディレクトリへのパス
DOTFILES_DIR="$HOME/dotfiles"

# zshの設定ファイルへのパス
ZSH_CONFIG_DIR="$HOME"
ZSH_INIT_FILE="$ZSH_CONFIG_DIR/.zshrc"

# Neovimの設定ファイルへのパス
NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_INIT_FILE="$NVIM_CONFIG_DIR/init.vim"

# zshの設定ファイルをdotfilesリポジトリからシンボリックリンクとして配置
link_zsh_config() {
  echo "Linking zsh config..."
  ln -sf "$DOTFILES_DIR/.zshrc" "$ZSH_INIT_FILE"
}

# Neovimの設定ファイルをdotfilesリポジトリからシンボリックリンクとして配置
link_nvim_config() {
  echo "Linking neovim config..."
  ln -sf "$DOTFILES_DIR/nvim/init.vim" "$NVIM_INIT_FILE"
}

# メインのスクリプト実行
main() {
  link_zsh_config
  link_nvim_config
  echo "Linking dotfiles completed."
}

main
