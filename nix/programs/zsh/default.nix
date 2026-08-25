{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;

    sessionVariables = {
      ZSH = "$HOME/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh";
      BUN_INSTALL = "$HOME/.bun";
      DOTFILES_DIR = "$HOME/ghq/github.com/mikinovation/dotfiles";
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
    };

    envExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
    ''
    + lib.optionalString pkgs.stdenv.hostPlatform.isLinux ''
      export PATH="$PATH:/opt/nvim/"
      export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    ''
    + lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
      export PATH="/opt/homebrew/bin:$PATH"
    ''
    + ''
      export PATH="$BUN_INSTALL/bin:$PATH"

      # fnm configuration
      # 非インタラクティブシェル（スクリプト・エディタ・AI エージェント経由の実行）でも
      # fnm 管理の Node.js を使うため .zshrc ではなく .zshenv 側で設定する
      FNM_PATH="$HOME/.local/share/fnm"
      if [ -d "$FNM_PATH" ]; then
        export PATH="$FNM_PATH:$PATH"
      fi
      if command -v fnm > /dev/null 2>&1; then
        # XDG_RUNTIME_DIR のディレクトリが存在しないと fnm の multishell シンボリックリンク作成に失敗し、
        # PATH が更新されず nix 側の nodejs にフォールバックしてしまうためフォールバック先を用意する
        if [ -n "$XDG_RUNTIME_DIR" ] && [ ! -d "$XDG_RUNTIME_DIR" ]; then
          export XDG_RUNTIME_DIR="/tmp/runtime-$UID"
          mkdir -p "$XDG_RUNTIME_DIR"
          chmod 700 "$XDG_RUNTIME_DIR"
        fi
        eval "$(fnm env --use-on-cd --shell zsh)"
      fi
    '';

    initContent = ''
      # Enable Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Load sheldon plugins
      eval "$(sheldon source)"

      # zoxide configuration (to avoid conflicts with claude code)
      if [[ $- == *i* ]]; then
        eval "$(zoxide init zsh --cmd cd)"
      else
        eval "$(zoxide init zsh --cmd z)"
      fi

      # Load WSL specific configurations if on WSL
      [[ -f "$DOTFILES_DIR/nix/programs/zsh/plugins/wsl.zsh" ]] && source "$DOTFILES_DIR/nix/programs/zsh/plugins/wsl.zsh"

      # Load zsh abbreviations
      [[ -f "$DOTFILES_DIR/nix/programs/zsh/plugins/abbr.zsh" ]] && source "$DOTFILES_DIR/nix/programs/zsh/plugins/abbr.zsh"

      # Load fzf integrations
      [[ -f "$DOTFILES_DIR/nix/programs/zsh/plugins/fzf.zsh" ]] && source "$DOTFILES_DIR/nix/programs/zsh/plugins/fzf.zsh"

      # Load Powerlevel10k configuration
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # bun completions
      [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
    '';
  };

  home.file.".p10k.zsh".source = ./plugins/.p10k.zsh;
}
