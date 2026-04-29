{ config, pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
  };

  home.file.".config/emacs/init.el".source = ./init.el;
}
