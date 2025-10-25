{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    # Install additional packages that neovim plugins might need
    extraPackages = with pkgs; [
      # Language servers
      lua-language-server

      # Formatters and linters
      stylua  # Lua formatter
    ];
  };

  # Session variables for neovim
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
