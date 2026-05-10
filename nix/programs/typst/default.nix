{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    typst
    tinymist
    typstyle
    typst-live
  ];
}
