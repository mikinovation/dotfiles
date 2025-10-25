{ config, pkgs, mcp-servers-nix, ... }:

let
  # Generate MCP configuration for Claude Code using lib.mkConfig
  mcpConfig = mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      # Playwright MCP Server (stdio connection)
      playwright = {
        enable = true;
      };

      # Serena MCP Server (stdio connection)
      serena = {
        enable = true;
        context = "ide-assistant";
      };

      # NixOS MCP Server (stdio connection)
      # Provides information about NixOS packages, options, and configurations
      nixos = {
        enable = true;
      };
    };

    # Custom servers not available as modules
    settings.servers = {
      # DeepWiki MCP Server (SSE connection)
      deepwiki = {
        url = "https://mcp.deepwiki.com/sse";
      };
    };
  };
in
{
  # Debug: Output mcpConfig JSON content
  warnings = [
    "MCP Config path: ${mcpConfig}"
    "MCP Config JSON: ${builtins.readFile "${mcpConfig}"}"
  ];

  # Write MCP configuration as JSON file
  home.file.".mcp.json".text = builtins.readFile "${mcpConfig}";

  # Add a convenient environment variable
  home.sessionVariables = {
    MCP_CONFIG_DIR = "${config.home.homeDirectory}/.config/claude";
  };
}
