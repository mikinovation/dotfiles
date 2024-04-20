#!/bin/bash

# dotfilesリポジトリのルートディレクトリへのパス
DOTFILES_DIR="$HOME/dotfiles"

# zshの設定ファイルへのパス
ZSH_CONFIG_DIR="$HOME"
ZSH_INIT_FILE="$ZSH_CONFIG_DIR/.zshrc"

# Neovimの設定ファイルへのパス
NVIM_CONFIG_DIR="$HOME/.config/nvim"

# zshの設定ファイルをdotfilesリポジトリからシンボリックリンクとして配置
link_zsh_config() {
  echo "Linking zsh config..."
  ln -snfv "$DOTFILES_DIR/.zshrc" "$ZSH_INIT_FILE"
  # source ~/.zshrc
  echo "Linking zsh done."
}

link_tmux_config() {
  echo "Linking tmux config..."
  ln -snfv "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"
  tmux source ~/.tmux.conf
  echo "Linking tmux done."
}

# Neovimの設定ファイルをdotfilesリポジトリからシンボリックリンクとして配置
link_nvim_config() {
  echo "Linking neovim config..."
  for file in "${DOTFILES_DIR}"/config/nvim); do
    [[ -f "$file" ]] || continue
    ln -snfv "$DOTFILES_DIR/config/nvim/$file" "$NVIM_CONFIG_DIR/$file"
  done
  ln -snfv "$DOTFILES_DIR/config/nvim/settings/coc-settings.json" "$NVIM_CONFIG_DIR/coc-settings.json"
  echo "Linking neovim done."
}

# メインのスクリプト実行
main() {
  echo "start setup dotfiles..."
  link_zsh_config
  link_tmux_config
  link_nvim_config
  echo "Linking dotfiles completed."
}

main
