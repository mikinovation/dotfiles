{ config, pkgs, username, ... }:

{
  imports = [ ./home-common.nix ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  xdg.configFile."nix/nix.conf".force = true;

  # Set zsh as default shell using activation script
  # This is necessary for standalone home-manager (non-NixOS)
  home.activation.make-zsh-default-shell = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    PATH="/usr/bin:/bin:$PATH"
    ZSH_PATH="${config.home.homeDirectory}/.nix-profile/bin/zsh"

    if [[ $(getent passwd ${config.home.username}) != *"$ZSH_PATH" ]]; then
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Nix settings
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
