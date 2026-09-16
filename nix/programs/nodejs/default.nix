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

      # markdown-preview.nvim のビルド (cd app && yarn install) が yarn を要求する
      yarn

      # Markdown や設定ファイルの整形に使う
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
