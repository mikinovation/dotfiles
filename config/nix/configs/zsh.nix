{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # Environment variables
    sessionVariables = {
      ZSH = "$HOME/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh";
      BUN_INSTALL = "$HOME/.bun";
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
    };

    # PATH additions
    envExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$PATH:/opt/nvim/"
      export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
      export PATH="$BUN_INSTALL/bin:$PATH"
    '';

    initContent = ''
      # Enable Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Load sheldon plugins
      eval "$(sheldon source)"

      # fnm configuration
      FNM_PATH="$HOME/.local/share/fnm"
      if [ -d "$FNM_PATH" ]; then
        export PATH="$FNM_PATH:$PATH"
        eval "`fnm env`"
      fi
      eval "$(fnm env --use-on-cd --shell zsh)"

      # zoxide configuration
      eval "$(zoxide init zsh --cmd cd)"

      # Load WSL specific configurations if on WSL
      [[ -f ~/dotfiles/config/zsh/plugins/wsl.zsh ]] && source ~/dotfiles/config/zsh/plugins/wsl.zsh

      # Load zsh abbreviations
      [[ -f ~/dotfiles/config/zsh/plugins/abbr.zsh ]] && source ~/dotfiles/config/zsh/plugins/abbr.zsh

      # Load Powerlevel10k configuration
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # bun completions
      [ -s "/home/mikinovation/.bun/_bun" ] && source "/home/mikinovation/.bun/_bun"
    '';
  };
}
