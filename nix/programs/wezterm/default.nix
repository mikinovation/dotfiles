{ lib, pkgs, ... }:

{
  # WSL では WezTerm を Windows ホスト側にインストールするため、
  # nixpkgs から入れるのは macOS のときだけ
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.wezterm ];

  home.file.".wezterm.lua".source = ./.wezterm.lua;
}
