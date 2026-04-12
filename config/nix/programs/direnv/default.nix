{ ... }:

{
  # direnv + nix-direnv for per-project environment management.
  #
  # The custom `use_pass` stdlib function loads GPG-encrypted secrets
  # from password-store under:
  #
  #   ~/.password-store/<project>/<env>/<VAR_NAME>
  #
  # where <project> defaults to the current git repository's basename
  # and <env> defaults to $APP_ENV (or "dev" if unset). This lets each
  # repository's `.envrc` be a single line:
  #
  #   use pass
  #
  # and individual envs are switched via the `projenv <env>` shell
  # function (defined in the zsh module), which re-triggers direnv.
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;

    stdlib = ''
      use_pass() {
        local project="''${1:-}"
        local env="''${2:-''${APP_ENV:-dev}}"

        if [[ -z "$project" ]]; then
          local toplevel
          toplevel=$(git rev-parse --show-toplevel 2>/dev/null) || {
            log_error "use_pass: project not given and not inside a git repository"
            return 1
          }
          project=$(basename "$toplevel")
        fi

        local prefix="$project/$env"
        if ! pass ls "$prefix" >/dev/null 2>&1; then
          log_error "use_pass: no pass entries under $prefix"
          return 1
        fi

        local keys
        keys=$(pass ls "$prefix" 2>/dev/null \
          | tail -n +2 \
          | sed 's/^[├└│─ ]*//' \
          | grep -v '^$')

        if [[ -z "$keys" ]]; then
          log_error "use_pass: empty prefix $prefix"
          return 1
        fi

        local key val
        while IFS= read -r key; do
          val=$(pass show "$prefix/$key" | head -n1)
          export "$key=$val"
          watch_file "$HOME/.password-store/$prefix/$key.gpg"
        done <<< "$keys"

        export APP_PROJECT="$project"
        export APP_ENV="$env"
      }
    '';
  };
}
