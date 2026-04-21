#!/bin/sh

set -eu

FLAKE_DIR="$(cd "$(dirname "$0")/../nix" && pwd)"

echo "=== Running nix flake check ==="
nix flake check "$FLAKE_DIR" --no-build

echo ""
echo "=== Dry-run home-manager build ==="
nix build "$FLAKE_DIR#homeConfigurations.mikinovation.activationPackage" --dry-run

echo ""
echo "=== Dry-run NixOS configuration build ==="
nix build "$FLAKE_DIR#nixosConfigurations.nixos.config.system.build.toplevel" --dry-run

echo ""
echo "All Nix checks passed."
