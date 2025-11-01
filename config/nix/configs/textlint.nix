{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (textlint.withPackages [ textlint-rule-preset-ja-technical-writing ])
  ];
}
