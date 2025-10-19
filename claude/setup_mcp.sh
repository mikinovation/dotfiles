#!/bin/bash

setup_claude_mcp() {
  echo "Setting up Claude MCP configuration..."
  
  if ! command -v claude >/dev/null 2>&1; then
    echo "Error: claude CLI is not installed or not in PATH"
    exit 1
  fi
  
  # Setup deepwiki
  echo "Adding deepwiki MCP server..."
  claude mcp add -t sse -s user deepwiki https://mcp.deepwiki.com/sse
  
  if [ $? -eq 0 ]; then
    echo "Deepwiki MCP server added successfully."
  else
    echo "Error: Failed to add deepwiki MCP server."
    exit 1
  fi
  
  # Setup playwright
  echo "Adding playwright MCP server..."
  claude mcp add -t stdio -s user playwright "npx" "@playwright/mcp@latest"

  if [ $? -eq 0 ]; then
    echo "Playwright MCP server added successfully."
  else
    echo "Error: Failed to add playwright MCP server."
    exit 1
  fi

  # Setup serena
  echo "Adding serena MCP server..."
  nix run github:oraios/serena -- start-mcp-server --transport stdio
  claude mcp add serena -- nix run github:oraios/serena -- start-mcp-server --transport stdio --context ide-assistant --project "$(pwd)"

  if [ $? -eq 0 ]; then
    echo "Serena MCP server added successfully."
  else
    echo "Error: Failed to add serena MCP server."
    exit 1
  fi
}

setup_claude_mcp
