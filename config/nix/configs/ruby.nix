{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Ruby version (3.4.x)
    ruby_3_4
    
    # Build dependencies for native extensions
    gcc
    gnumake
    
    # Development tools
    rubyPackages.solargraph  # Ruby language server
  ];

  # Environment variables for Ruby
  home.sessionVariables = {
    # Gem installation directory
    GEM_HOME = "${config.home.homeDirectory}/.gem";
    GEM_PATH = "${config.home.homeDirectory}/.gem";
  };

  # Add gem bin to PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/.gem/bin"
  ];

  # Create .gemrc configuration
  home.file.".gemrc".text = ''
    gem: --no-document
    install: --user-install
    update: --user-install
  '';

  # Create bundler config directory
  home.file.".bundle/config".text = ''
    ---
    BUNDLE_PATH: ".bundle/vendor"
    BUNDLE_BIN: ".bundle/bin"
  '';
}
