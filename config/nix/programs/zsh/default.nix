{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # Environment variables
    sessionVariables = {
      ZSH = "$HOME/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh";
      BUN_INSTALL = "$HOME/.bun";
      DOTFILES_DIR = "$HOME/ghq/github.com/mikinovation/dotfiles";
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
      # Auto-start tmux on WSL launch
      if grep -qi microsoft /proc/version 2>/dev/null \
        && command -v tmux &> /dev/null \
        && [ -z "$TMUX" ] && [ -z "$INSIDE_EMACS" ] && [ -z "$VSCODE_RESOLVING_ENVIRONMENT" ]; then
        TMUX_START_DIR="$HOME/ghq/github.com/mikinovation/org"
        [ -d "$TMUX_START_DIR" ] || TMUX_START_DIR="$HOME"
        exec tmux new-session -A -s main -c "$TMUX_START_DIR"
      fi

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

      # zoxide configuration (to avoid conflicts with claude code)
      if [[ $- == *i* ]]; then
        eval "$(zoxide init zsh --cmd cd)"
      else
        eval "$(zoxide init zsh --cmd z)"
      fi

      # Load WSL specific configurations if on WSL
      [[ -f "$DOTFILES_DIR/config/zsh/plugins/wsl.zsh" ]] && source "$DOTFILES_DIR/config/zsh/plugins/wsl.zsh"

      # Load zsh abbreviations
      [[ -f "$DOTFILES_DIR/config/zsh/plugins/abbr.zsh" ]] && source "$DOTFILES_DIR/config/zsh/plugins/abbr.zsh"

      # Load fzf integrations
      [[ -f "$DOTFILES_DIR/config/zsh/plugins/fzf.zsh" ]] && source "$DOTFILES_DIR/config/zsh/plugins/fzf.zsh"

      # Load Powerlevel10k configuration
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # bun completions
      [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

      # pass (password-store) environment variable helpers.
      # Secrets live in ~/.password-store and are expected to be kept in
      # a separate private repository; nothing from the store is committed
      # to this public dotfiles repo.
      passenv() {
        local env="''${1:-dev}"
        local prefix="env/$env"
        if ! pass ls "$prefix" >/dev/null 2>&1; then
          echo "passenv: no entries under $prefix" >&2
          return 1
        fi

        local keys
        keys=$(pass ls "$prefix" 2>/dev/null \
          | tail -n +2 \
          | sed 's/^[├└│─ ]*//' \
          | grep -v '^$')

        if [[ -z "$keys" ]]; then
          echo "passenv: no entries under $prefix" >&2
          return 1
        fi

        export PASS_ENV_LOADED_KEYS=""
        local key val
        while IFS= read -r key; do
          val=$(pass show "$prefix/$key" | head -n1)
          export "$key=$val"
          PASS_ENV_LOADED_KEYS="$PASS_ENV_LOADED_KEYS $key"
        done <<< "$keys"

        export PASS_ENV="$env"
        echo "passenv: loaded '$env' ($(echo "$keys" | wc -l) vars)"
      }

      passenv-unset() {
        if [[ -z "$PASS_ENV_LOADED_KEYS" ]]; then
          return 0
        fi
        local key
        for key in $PASS_ENV_LOADED_KEYS; do
          unset "$key"
        done
        unset PASS_ENV PASS_ENV_LOADED_KEYS
      }

      passrun() {
        if [[ $# -lt 2 ]]; then
          echo "usage: passrun <env> <command> [args...]" >&2
          return 2
        fi
        local env="$1"; shift
        (
          passenv "$env" >/dev/null || exit 1
          "$@"
        )
      }
    '';
  };
}
