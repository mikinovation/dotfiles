{ config, pkgs, mcp-servers-nix, ... }:

let
  # Generate MCP configuration for Claude Code using lib.mkConfig
  mcpConfig = mcp-servers-nix.lib.mkConfig pkgs {
    programs = {
      # Playwright MCP Server (stdio connection)
      playwright = {
        enable = true;
      };

      # NixOS MCP Server (stdio connection)
      # Provides information about NixOS packages, options, and configurations
      nixos = {
        enable = false;
      };
    };

    # Custom servers not available as modules
    settings.servers = {
      # DeepWiki MCP Server (SSE connection)
      deepwiki = {
        type = "sse";
        url = "https://mcp.deepwiki.com/sse";
      };
    };
  };
in
{
  # Write MCP configuration as JSON file
  home.file.".mcp.json".text = builtins.readFile "${mcpConfig}";
}
