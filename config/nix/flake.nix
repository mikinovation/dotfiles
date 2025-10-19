{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Home Manager configuration
      homeConfigurations = {
        # Replace with your username
        mikinovation = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix ];
        };
      };

      # Keep existing devShells for development
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.hello ];
      };

      # Keep existing packages
      packages.${system}.default = pkgs.hello;
    };
}
