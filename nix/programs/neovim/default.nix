{
  config,
  lib,
  pkgs,
  profile,
  vueLanguageServer,
  ...
}:

let
  isFull = profile == "full";

  devLanguageServers = (
    with pkgs;
    [
      rust-analyzer
      vtsls
      tailwindcss-language-server
      vscode-langservers-extracted # HTML, CSS, JSON, ESLint
      solargraph # Ruby
    ]
  )
  ++ [
    vueLanguageServer # Vue (volar) — local build to avoid nixpkgs pnpm dep
  ];
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;
    withPython3 = false;

    # Install additional packages that neovim plugins might need
    extraPackages =
      (with pkgs; [
        # Language servers
        lua-language-server
        nil # Nix

        # Tree-sitter parser build tools
        tree-sitter
        (if stdenv.hostPlatform.isDarwin then clang else gcc)
        gnumake

        # Lua runtime and package manager (required for luarocks plugin deps)
        lua5_1
        luarocks

        # Formatters and linters
        stylua # Lua formatter
        luajitPackages.luacheck # Lua linter
        luajitPackages.busted # Lua testing framework
      ])
      ++ lib.optionals isFull devLanguageServers;
  };

  home.file.".config/nvim".source = pkgs.lib.cleanSourceWith {
    src = ./nvim;
    filter =
      path: type:
      let
        baseName = baseNameOf path;
      in
      baseName != "lazy-lock.json";
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
