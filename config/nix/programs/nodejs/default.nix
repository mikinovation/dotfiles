{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Node.js LTS version (includes npm by default)
    nodejs_22

    # Package managers
    yarn
    nodePackages.pnpm

    # Development tools
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.eslint
    nodePackages.prettier
    typescript-go # Go implementation of TypeScript
  ];

  # Create .npmrc configuration
  home.file.".npmrc".text = ''
    save-exact=true
    engine-strict=true
  '';
}
