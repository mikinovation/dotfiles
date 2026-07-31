{
  config,
  pkgs,
  vueLanguageServer,
  ...
}:

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
        rust-analyzer
        vtsls
        tailwindcss-language-server
        vscode-langservers-extracted # HTML, CSS, JSON, ESLint
        nil # Nix
        solargraph # Ruby

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
      ])
      ++ [
        vueLanguageServer # Vue (volar) — local build to avoid nixpkgs pnpm dep
      ];

    # sqlite.lua loads libsqlite3 by ffi and only probes FHS paths such as
    # /usr/lib/libsqlite3.so, none of which exist on NixOS. Hand it the store
    # path instead; plugins/sqlite/init.lua turns this into vim.g.sqlite_clib_path.
    # Without it yanky's ring storage and telescope-frecency both fail.
    extraWrapperArgs = [
      "--set"
      "NVIM_SQLITE_CLIB_PATH"
      "${pkgs.sqlite.out}/lib/libsqlite3.so"
    ];
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
