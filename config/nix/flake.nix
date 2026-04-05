# https://github.com/renovatebot/renovate/issues/29721
# Trick renovate into working: "github:NixOS/nixpkgs/nixpkgs-unstable"
{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agent-skills-nix = {
      url = "github:Kyure-A/agent-skills-nix";
    };
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
    agent-browser = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };
    vercel-skills = {
      url = "github:vercel-labs/skills";
      flake = false;
    };
    antfu-skills = {
      url = "github:antfu/skills";
      flake = false;
    };
    obra-superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-wsl,
      home-manager,
      mcp-servers-nix,
      agent-skills-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      nodePkgs = import ../node2nix/default.nix { inherit pkgs; };
      mkHomeConfig =
        username:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
            agent-skills-nix.homeManagerModules.default
            mcp-servers-nix.homeManagerModules.default
          ];
          extraSpecialArgs = {
            inherit inputs nodePkgs username;
          };
        };
      mkNixosConfig =
        username: hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username;
          };
          modules = [
            nixos-wsl.nixosModules.wsl
            ./nixos/configuration.nix
            home-manager.nixosModules.home-manager
            {
              networking.hostName = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit inputs nodePkgs username;
              };
              home-manager.sharedModules = [
                agent-skills-nix.homeManagerModules.default
                mcp-servers-nix.homeManagerModules.default
              ];
            }
          ];
        };
    in
    {
      # NixOS system configuration
      nixosConfigurations = {
        nixos = mkNixosConfig "nixos" "nixos";
      };

      # Home Manager configuration (standalone)
      homeConfigurations = {
        mikinovation = mkHomeConfig "mikinovation";
        nixos = mkHomeConfig "nixos";
      };

      # Nix formatter
      formatter.${system} = pkgs.nixfmt-rfc-style;

      # Nix flake checks
      checks.${system} = {
        home-manager-build = self.homeConfigurations.mikinovation.activationPackage;
        nixos-build = self.nixosConfigurations.nixos.config.system.build.toplevel;
      };
    };
}
