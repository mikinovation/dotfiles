{
  config,
  lib,
  pkgs,
  profile,
  ...
}:

let
  isFull = profile == "full";
in
{
  home.packages =
    with pkgs;
    [
      # Node.js LTS version (includes npm by default)
      nodejs_22
      yarn
      prettier
    ]
    ++ lib.optionals isFull [
      pnpm
      typescript
      typescript-language-server
      eslint
    ];

  # Create .npmrc configuration
  home.file.".npmrc".text = ''
    save-exact=true
    engine-strict=true
  '';
}
