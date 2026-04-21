{ pkgs, ... }:

{
  home.packages = [ pkgs.sheldon ];

  home.file.".config/sheldon/plugins.toml".source = ./plugins.toml;
}
