{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    ignores = [
      ".serena/"
    ];

    extraConfig = {
      fetch = {
        prune = true;
        pruneTags = true;
      };
    };
  };
}
