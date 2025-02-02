{
  description = "My Nix config for x86_64-linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    vim-src = {
      url = "github:vim/vim";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    neovim-nightly-overlay,
    vim-src,
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system}.extend (
      neovim-nightly-overlay.overlays.default
    );
  in {
    packages.${system}.default = pkgs.buildEnv {
      name = "my-packages";
      paths = with pkgs; [
        bun
        cargo
        clippy
        curl
        deno
        docker
        fnm
        fzf
        gh
        git
        go
        jq
        nano
        nodejs_22
        pnpm
        ripgrep
        unzip
        vue-language-server
        wget
        yarn

        (vim.overrideAttrs (oldAttrs: {
          version = "latest";
          src = vim-src;
          configureFlags =
            oldAttrs.configureFlags
            ++ [
              "--enable-terminal"
              "--with-compiledby=mikinovation-nix"
              "--enable-luainterp"
              "--with-lua-prefix=${lua}"
              "--enable-fail-if-missing"
            ];
          buildInputs = oldAttrs.buildInputs ++ [
            gettext
            lua
            libiconv
          ];
        }))

        neovim
      ];
    };

    apps.${system}.update = {
      type = "app";
      program = toString (pkgs.writeShellScript "update-script" ''
        set -e
        echo "Updating flake..."
        nix flake update
        echo "Updating profile..."
        if ! nix profile upgrade my-packages; then
          echo "Failed to upgrade profile!"
          exit 1
        fi
        echo "Update complete!"
      '');
    };
  };
}
