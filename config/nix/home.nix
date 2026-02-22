{ config, pkgs, ... }:

{
  imports = [ ./home-common.nix ];

  home.username = "mikinovation";
  home.homeDirectory = "/home/mikinovation";

  home.stateVersion = "24.05";

  xdg.configFile."nix/nix.conf".force = true;

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

  programs.home-manager.enable = true;

  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
}
