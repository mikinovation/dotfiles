{ pkgs, ... }:

{
  wsl.enable = true;
  wsl.defaultUser = "nixos";

  networking.hostName = "nixos";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.groups.nixos.gid = 1000;
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    uid = 1000;
    group = "nixos";
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    ghq
  ];

  system.stateVersion = "25.11";
}
