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
    typescript-go  # Go implementation of TypeScript
  ];

  # Environment variables for Node.js
  home.sessionVariables = {
    # npm global packages directory
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  };

  # Add npm global bin to PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
  ];

  # Create .npmrc configuration
  home.file.".npmrc".text = ''
    prefix=''${HOME}/.npm-global
    save-exact=true
    engine-strict=true
  '';
}
