{
  config,
  lib,
  pkgs,
  nodePkgs,
  inputs,
  username,
  apm,
  ...
}:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    fnm # Fast Node Manager
    uv # Python package manager
    zoxide # Smart cd replacement
    fzf # Fuzzy finder
    ripgrep # Fast grep alternative
    ghq # Git repository organizer
    jq # JSON processor
    curl # HTTP client
    lsof # List open files
    pandoc # Document format converter
    apm
    nodePkgs."agent-browser"
    nodePkgs."ccmanager"
    nodePkgs."@vue/language-server"
    nodePkgs."@vue/typescript-plugin"
  ];

  imports = [
    ./programs/git
    ./programs/zsh
    ./programs/neovim
    ./programs/nodejs
    ./programs/ruby
    ./programs/rust
    ./programs/database
    ./programs/agent-browser
    ./programs/claude-code
    ./programs/textlint
    ./programs/agent-skills
    ./programs/tmux
    ./programs/aws
    ./programs/wezterm
    ./programs/sheldon
  ];

  home.sessionVariables = { };

  xdg.configFile."nix/nix.conf".force = true;

  home.activation.make-zsh-default-shell = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    PATH="/run/current-system/sw/bin:/usr/bin:/bin:$PATH"
    ZSH_PATH="${config.home.homeDirectory}/.nix-profile/bin/zsh"

    if [ -e /etc/NIXOS ]; then
      echo "NixOS detected, skipping shell change (managed by NixOS config)"
    elif [[ $(getent passwd ${config.home.username}) != *"$ZSH_PATH" ]]; then
      echo "Setting zsh as default shell (using chsh). Password might be necessary."

      if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "Adding zsh to /etc/shells"
        $DRY_RUN_CMD echo "$ZSH_PATH" | sudo tee -a /etc/shells
      fi

      echo "Running chsh to make zsh the default shell"
      $DRY_RUN_CMD chsh -s "$ZSH_PATH" ${config.home.username}
      echo "Zsh is now set as default shell!"
    else
      echo "Zsh is already the default shell"
    fi
  '';

  programs.home-manager.enable = true;

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
