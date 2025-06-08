#!/bin/bash

setup_claude_mcp() {
  echo "Setting up Claude MCP configuration..."
  
  if ! command -v claude >/dev/null 2>&1; then
    echo "Error: claude CLI is not installed or not in PATH"
    exit 1
  fi
  
  claude mcp add -t sse -s user deepwiki https://mcp.deepwiki.com/sse
  
  if [ $? -eq 0 ]; then
    echo "Claude MCP configuration added successfully."
  else
    echo "Error: Failed to add Claude MCP configuration."
    exit 1
  fi
}

setup_claude_mcp
