{ pkgs, ... }:

{
  networking.hostName = "nixos-wsl";

  wsl = {
    enable = true;
    defaultUser = "mikinovation";

    interop = {
      register = true;
    };

    wslConf = {
      automount.root = "/mnt";
      network.generateResolvConf = true;
    };
  };

  users.users.mikinovation = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
  };

  programs.zsh.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Asia/Tokyo";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "mikinovation" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "24.05";
}
