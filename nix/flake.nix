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
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
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
    herdr = {
      url = "github:ogulcancelik/herdr";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-wsl,
      nix-darwin,
      home-manager,
      mcp-servers-nix,
      agent-skills-nix,
      ...
    }:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      systems = [
        linuxSystem
        darwinSystem
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

      mkExtraArgs =
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          apm = pkgs.callPackage ./pkgs/apm.nix { };
          claudeCode = pkgs.callPackage ./pkgs/claude-code.nix { };
          vueLanguageServer = pkgs.callPackage ./pkgs/vue-language-server.nix { };
          vueTypescriptPlugin = pkgs.callPackage ./pkgs/vue-typescript-plugin.nix { };
          difit = pkgs.callPackage ./pkgs/difit.nix { };
          chromeDevtoolsMcp = pkgs.callPackage ./pkgs/chrome-devtools-mcp.nix { };
          headroom = pkgs.callPackage ./pkgs/headroom.nix { };
          herdr = inputs.herdr.packages.${system}.default;
        };

      homeManagerModules = [
        agent-skills-nix.homeManagerModules.default
        mcp-servers-nix.homeManagerModules.default
      ];

      lintApp =
        pkgs:
        pkgs.writeShellApplication {
          name = "lint";
          runtimeInputs = [
            pkgs.lua51Packages.luacheck
            pkgs.git
          ];
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
      fmtApp =
        pkgs:
        pkgs.writeShellApplication {
          name = "fmt";
          runtimeInputs = [ pkgs.stylua ];
          text = ''
            echo "=== Running stylua check ==="
            stylua --check .
          '';
        };
      testApp =
        pkgs:
        pkgs.writeShellApplication {
          name = "test";
          runtimeInputs = [ pkgs.lua51Packages.busted ];
          text = ''
            echo "=== Running busted tests ==="
            busted .
          '';
        };

      mkHomeConfig =
        {
          username,
          system,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = pkgsFor system;
          modules = [ ./home.nix ] ++ homeManagerModules;
          extraSpecialArgs = (mkExtraArgs system) // {
            inherit inputs username;
          };
        };

      mkNixosConfig =
        username: hostname:
        nixpkgs.lib.nixosSystem {
          system = linuxSystem;
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
              home-manager.extraSpecialArgs = (mkExtraArgs linuxSystem) // {
                inherit inputs username;
              };
              home-manager.sharedModules = homeManagerModules;
            }
          ];
        };

      mkDarwinConfig =
        username: hostname:
        nix-darwin.lib.darwinSystem {
          system = darwinSystem;
          specialArgs = {
            inherit inputs username;
          };
          modules = [
            ./darwin/configuration.nix
            home-manager.darwinModules.home-manager
            {
              networking.hostName = hostname;
              networking.computerName = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home.nix;
              home-manager.extraSpecialArgs = (mkExtraArgs darwinSystem) // {
                inherit inputs username;
              };
              home-manager.sharedModules = homeManagerModules;
            }
          ];
        };
    in
    {
      # NixOS system configuration (WSL)
      nixosConfigurations = {
        nixos = mkNixosConfig "nixos" "nixos";

        wsl-bootstrap = nixpkgs.lib.nixosSystem {
          system = linuxSystem;
          modules = [
            nixos-wsl.nixosModules.wsl
            ./nixos/wsl-bootstrap.nix
          ];
        };
      };

      # nix-darwin system configuration (macOS)
      darwinConfigurations = {
        mac = mkDarwinConfig "mikinovation" "mac";
      };

      # Home Manager configuration (standalone, non-NixOS Linux)
      homeConfigurations = {
        mikinovation = mkHomeConfig {
          username = "mikinovation";
          system = linuxSystem;
        };
        nixos = mkHomeConfig {
          username = "nixos";
          system = linuxSystem;
        };
      };

      # Nix formatter
      formatter = forAllSystems (system: (pkgsFor system).nixfmt-rfc-style);

      # Nix flake checks
      checks = {
        ${linuxSystem} = {
          home-manager-build = self.homeConfigurations.mikinovation.activationPackage;
          nixos-build = self.nixosConfigurations.nixos.config.system.build.toplevel;
        };
        ${darwinSystem} = {
          darwin-build = self.darwinConfigurations.mac.system;
        };
      };

      # Dev shell with all local check tools
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              pkgs.lua51Packages.luacheck
              pkgs.lua51Packages.busted
              pkgs.stylua
              pkgs.nodejs_22
            ];
          };
        }
      );

      # Apps: nix run .#lint / .#fmt / .#test
      apps = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          lint = {
            type = "app";
            program = "${lintApp pkgs}/bin/lint";
          };
          fmt = {
            type = "app";
            program = "${fmtApp pkgs}/bin/fmt";
          };
          test = {
            type = "app";
            program = "${testApp pkgs}/bin/test";
          };
        }
      );
    };
}
