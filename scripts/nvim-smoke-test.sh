#!/bin/sh

# Smoke test: verify Neovim starts without errors in headless mode.
# This catches issues like missing modules or broken init.lua that
# only surface in the actual Nix runtime environment.

main() {
  echo "Neovim smoke test started..."

  if ! command -v nvim > /dev/null 2>&1; then
    echo "nvim not found, skipping smoke test"
    exit 0
  fi

  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  export XDG_CONFIG_HOME="$(cd "$SCRIPT_DIR/../config" && pwd)"

  # Create directories referenced by config to avoid warnings
  mkdir -p "$HOME/ghq/github.com/mikinovation/org"

  # First pass: install plugins via lazy.nvim
  echo "Installing plugins..."
  nvim --headless "+Lazy! sync" +qa 2>&1 || true

  # Second pass: verify clean startup with no errors
  echo "Verifying clean startup..."
  if error_output=$(nvim --headless -c 'quit' 2>&1) && [ -z "$error_output" ]; then
    echo "Neovim smoke test passed!"
  else
    echo "Neovim smoke test failed! Startup errors detected:"
    [ -n "$error_output" ] && echo "$error_output"
    exit 1
  fi
}

main
