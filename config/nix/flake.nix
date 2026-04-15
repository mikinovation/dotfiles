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
    claude-code-plugins = {
      url = "github:anthropics/claude-code";
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
      lintApp = pkgs.writeShellApplication {
        name = "lint";
        runtimeInputs = [ pkgs.lua51Packages.luacheck pkgs.git ];
        text = ''
          echo "=== Running luacheck ==="
          luacheck .

          echo ""
          echo "=== Running secretlint ==="
          if [ -x "./node_modules/.bin/secretlint" ]; then
            git ls-files -z | xargs -0 ./node_modules/.bin/secretlint
          else
            echo "Warning: secretlint not found. Run 'npm ci' first."
            exit 1
          fi
        '';
      };
      fmtApp = pkgs.writeShellApplication {
        name = "fmt";
        runtimeInputs = [ pkgs.stylua ];
        text = ''
          echo "=== Running stylua check ==="
          stylua --check .
        '';
      };
      testApp = pkgs.writeShellApplication {
        name = "test";
        runtimeInputs = [ pkgs.lua51Packages.busted ];
        text = ''
          echo "=== Running busted tests ==="
          busted .
        '';
      };
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

      # Dev shell with all local check tools
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.lua51Packages.luacheck
          pkgs.lua51Packages.busted
          pkgs.stylua
          pkgs.nodejs_22
        ];
      };

      # Apps: nix run .#lint / .#fmt / .#test
      apps.${system} = {
        lint = {
          type = "app";
          program = "${lintApp}/bin/lint";
        };
        fmt = {
          type = "app";
          program = "${fmtApp}/bin/fmt";
        };
        test = {
          type = "app";
          program = "${testApp}/bin/test";
        };
      };
    };
}
