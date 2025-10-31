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

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
    };
  };
}
