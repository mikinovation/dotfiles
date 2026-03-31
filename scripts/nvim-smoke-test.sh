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

  # First pass: install plugins via lazy.nvim (skip if already installed)
  echo "Installing plugins..."
  nvim --headless "+Lazy! install" +qa 2>&1 || true

  # Second pass: verify clean startup by capturing all errors and warnings
  # Uses two Lua scripts:
  #   hook   (--cmd): runs BEFORE init.lua — hooks vim.notify
  #   result (-c)   : runs AFTER init.lua  — checks results + lazy state
  # NOTE: Do not redirect nvim's stdout/stderr — some plugins behave
  # differently when output is redirected, which can suppress errors.
  echo "Verifying clean startup..."
  export SMOKE_RESULT_FILE=$(mktemp)
  trap 'rm -f "$SMOKE_RESULT_FILE"' EXIT

  nvim --headless \
    --cmd "luafile $SCRIPT_DIR/nvim-smoke-check-hook.lua" \
    -c "luafile $SCRIPT_DIR/nvim-smoke-check-result.lua"
  nvim_exit=$?

  notify_errors=$(grep "^ERROR:" "$SMOKE_RESULT_FILE" 2>/dev/null | sed 's/^ERROR://')
  notify_warnings=$(grep "^WARN:" "$SMOKE_RESULT_FILE" 2>/dev/null | sed 's/^WARN://')

  if [ -n "$notify_errors" ] || { [ $nvim_exit -ne 0 ] && [ $nvim_exit -ne 2 ]; }; then
    echo "Neovim smoke test failed! Errors detected:"
    [ -n "$notify_errors" ] && echo "[error] $notify_errors"
    [ -n "$notify_warnings" ] && echo "[warning] $notify_warnings"
    exit 1
  fi

  if [ -n "$notify_warnings" ]; then
    echo "Neovim smoke test failed! Warnings detected:"
    echo "[warning] $notify_warnings"
    exit 1
  fi

  echo "Neovim smoke test passed!"
}

main
