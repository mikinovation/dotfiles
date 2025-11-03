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
      rust-analyzer
      vtsls
      tailwindcss-language-server
      vscode-langservers-extracted  # HTML, CSS, JSON, ESLint
      solargraph  # Ruby
      vue-language-server  # Vue (volar)

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
