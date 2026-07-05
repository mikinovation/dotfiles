{ pkgs, ... }:

{
  wsl.enable = true;
  wsl.defaultUser = "nixos";

  networking.hostName = "nixos";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    ghq
  ];

  system.stateVersion = "25.11";
}
