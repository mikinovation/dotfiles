{
  config,
  lib,
  pkgs,
  inputs,
  username,
  profile,
  apm,
  claudeCode,
  vueLanguageServer,
  vueTypescriptPlugin,
  difit,
  herdr,
  ...
}:

let
  isFull = profile == "full";
in
{
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.hostPlatform.isDarwin then "/Users/${username}" else "/home/${username}";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages =
    with pkgs;
    [
      fnm # Fast Node Manager
      zoxide # Smart cd replacement
      fzf # Fuzzy finder
      ripgrep # Fast grep alternative
      ghq # Git repository organizer
      jq # JSON processor
      curl # HTTP client
      lsof # List open files
      pandoc # Document format converter
      apm # Agent Package Manager
      difit # Git diff web UI (nvim の :Difit から使う)
      herdr
    ]
    ++ lib.optionals isFull [
      vueLanguageServer
      vueTypescriptPlugin
    ];

  imports = [
    ./programs/git
    ./programs/zsh
    ./programs/neovim
    ./programs/nodejs
    ./programs/claude-code
    ./programs/textlint
    ./programs/agent-skills
    ./programs/herdr
    ./programs/wezterm
    ./programs/sheldon
    ./programs/typst
    ./programs/direnv
  ]
  ++ lib.optionals isFull [
    ./programs/emacs
    ./programs/ruby
    ./programs/rust
    ./programs/database
    ./programs/agent-browser
    ./programs/aws
    ./programs/python
    ./programs/terraform
    ./programs/onepassword
  ];

  home.sessionVariables = {
    DOTFILES_PROFILE = profile;
  };

  xdg.configFile."nix/nix.conf".force = true;

  # macOS では nix-darwin の users.users.<name>.shell が既定シェルを管理するため、
  # getent / chsh に依存するこのスクリプトは Linux 限定にする
  home.activation = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    make-zsh-default-shell = config.lib.dag.entryAfter [ "writeBoundary" ] ''
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
  };

  programs.home-manager.enable = true;

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    gc = lib.mkIf (!isFull) {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
