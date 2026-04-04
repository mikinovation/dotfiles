#!/bin/sh

set -eu

FLAKE_DIR="$(cd "$(dirname "$0")/../config/nix" && pwd)"

echo "=== Running nix fmt check ==="
nix fmt "$FLAKE_DIR" -- --check

echo ""
echo "Nix format check passed."
