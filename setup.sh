#!/bin/bash

# dotfilesリポジトリのルートディレクトリへのパス
DOTFILES_DIR="$HOME/dotfiles"

# Neovimの設定ファイルへのパス
NVIM_CONFIG_DIR="$HOME/.config/nvim"

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

# メインのスクリプト実行
main() {
  echo "start setup dotfiles..."
  link_nvim_config
  echo "Linking dotfiles completed."
}

main
