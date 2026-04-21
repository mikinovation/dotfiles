#!/bin/sh

set -eu

FLAKE_DIR="$(cd "$(dirname "$0")/../nix" && pwd)"

echo "=== Running nix fmt check ==="
cd "$FLAKE_DIR"
find . -name '*.nix' -not -path './node2nix/*' -print0 | xargs -0 nix fmt -- --check

echo ""
echo "Nix format check passed."
