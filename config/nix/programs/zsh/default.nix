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

      # ----------------------------------------------------------------
      # password-store based environment variable helpers.
      #
      # Two hierarchies are supported in parallel:
      #   ~/.password-store/env/<env>/<KEY>           # global
      #   ~/.password-store/<project>/<env>/<KEY>     # project-scoped
      # where <project> conventionally matches the git repo basename.
      #
      # The store itself lives in a separate PRIVATE repository; nothing
      # from it is committed to this public dotfiles repo.
      # ----------------------------------------------------------------

      # Internal: list leaf entry names under a pass prefix.
      _passenv_list_keys() {
        pass ls "$1" 2>/dev/null \
          | tail -n +2 \
          | sed 's/^[├└│─ ]*//' \
          | grep -v '^$'
      }

      # Internal: resolve args into a pass prefix.
      #   one arg without '/'  -> env/<arg>   (global shorthand)
      #   one arg with '/'     -> the arg itself (explicit path)
      #   two args             -> <project>/<env>
      _passenv_prefix() {
        case $# in
          1)
            if [[ "$1" == */* ]]; then
              printf '%s\n' "$1"
            else
              printf 'env/%s\n' "$1"
            fi
            ;;
          2) printf '%s/%s\n' "$1" "$2" ;;
          *) return 2 ;;
        esac
      }

      passenv() {
        local prefix
        if ! prefix=$(_passenv_prefix "$@"); then
          echo "usage: passenv <env>                  # global env/<env>/*" >&2
          echo "       passenv <project> <env>        # <project>/<env>/*" >&2
          echo "       passenv <project>/<env>        # explicit path" >&2
          return 2
        fi

        if ! pass ls "$prefix" >/dev/null 2>&1; then
          echo "passenv: no entries under $prefix" >&2
          return 1
        fi

        local keys
        keys=$(_passenv_list_keys "$prefix")
        if [[ -z "$keys" ]]; then
          echo "passenv: empty prefix $prefix" >&2
          return 1
        fi

        export PASS_ENV_LOADED_KEYS=""
        local key val
        while IFS= read -r key; do
          val=$(pass show "$prefix/$key" | head -n1)
          export "$key=$val"
          PASS_ENV_LOADED_KEYS="$PASS_ENV_LOADED_KEYS $key"
        done <<< "$keys"

        if [[ "''${prefix%%/*}" == "env" ]]; then
          export APP_PROJECT="global"
          export APP_ENV="''${prefix#env/}"
        else
          export APP_PROJECT="''${prefix%%/*}"
          export APP_ENV="''${prefix#*/}"
        fi
        echo "passenv: loaded '$prefix' ($(echo "$keys" | wc -l) vars)"
      }

      passenv-unset() {
        [[ -z "''${PASS_ENV_LOADED_KEYS:-}" ]] && return 0
        local key
        for key in $PASS_ENV_LOADED_KEYS; do
          unset "$key"
        done
        unset PASS_ENV_LOADED_KEYS APP_PROJECT APP_ENV
      }

      passrun() {
        if [[ $# -lt 2 ]]; then
          echo "usage: passrun <prefix> <cmd...>          (prefix must contain /)" >&2
          echo "       passrun <project> <env> <cmd...>" >&2
          return 2
        fi
        local prefix
        if [[ "$1" == */* ]]; then
          prefix="$1"; shift
        else
          if [[ $# -lt 3 ]]; then
            echo "passrun: need <project> <env> <cmd...> when first arg has no /" >&2
            return 2
          fi
          prefix="$1/$2"; shift 2
        fi
        (
          passenv "$prefix" >/dev/null || exit 1
          "$@"
        )
      }

      # Switch APP_ENV in the current direnv-managed directory and reload.
      projenv() {
        if ! command -v direnv >/dev/null 2>&1; then
          echo "projenv: direnv not found" >&2
          return 1
        fi
        export APP_ENV="''${1:-dev}"
        direnv reload
      }

      # Clear the manual APP_ENV override and let direnv re-evaluate.
      projenv-reset() {
        unset APP_ENV
        command -v direnv >/dev/null 2>&1 && direnv reload
      }

      # Powerlevel10k segment: show <project>:<env> in the right prompt.
      # Prod is red to discourage accidents; staging yellow, dev green.
      function prompt_app_env() {
        [[ -z "''${APP_ENV:-}" ]] && return
        local color=blue
        case "$APP_ENV" in
          prod|production) color=red ;;
          stg|staging)     color=yellow ;;
          dev|development) color=green ;;
        esac
        p10k segment -f "$color" -t "''${APP_PROJECT:-?}:$APP_ENV"
      }
      typeset -ga POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(app_env)
    '';
  };
}
