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
      vscode-langservers-extracted # HTML, CSS, JSON, ESLint
      solargraph # Ruby
      vue-language-server # Vue (volar)

      # Tree-sitter parser build tools
      tree-sitter
      gcc

      # Lua runtime and package manager (required for luarocks plugin deps)
      lua5_1
      luarocks

      # Formatters and linters
      stylua # Lua formatter
      luajitPackages.luacheck # Lua linter
      luajitPackages.busted # Lua testing framework
    ];
  };

  # Session variables for neovim
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
