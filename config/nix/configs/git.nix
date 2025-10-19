{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    extraConfig = {
      fetch = {
        prune = true;
        pruneTags = true;
      };
    };
  };
}
