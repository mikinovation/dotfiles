{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js LTS version (includes npm by default)
    nodejs_22

    # Package managers
    yarn
    pnpm

    # Development tools
    typescript
    typescript-language-server
    eslint
    prettier
    typescript-go # Go implementation of TypeScript
  ];

  # Create .npmrc configuration
  home.file.".npmrc".text = ''
    save-exact=true
    engine-strict=true
  '';
}
