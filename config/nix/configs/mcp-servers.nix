{ config, pkgs, mcp-servers-nix, ... }:

mcp-servers-nix.lib.mkConfig pkgs {
  format = "json";
  flavor = "claude";
  fileName = ".claude.json";

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
