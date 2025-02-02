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
        git
        curl

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
        nix profile upgrade my-packages
        echo "Update complete!"
      '');
    };
  };
}
