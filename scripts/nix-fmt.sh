#!/bin/sh

set -eu

FLAKE_DIR="$(cd "$(dirname "$0")/../config/nix" && pwd)"

echo "=== Running nix fmt check ==="
cd "$FLAKE_DIR"
nix fmt -- --check .

echo ""
echo "Nix format check passed."
