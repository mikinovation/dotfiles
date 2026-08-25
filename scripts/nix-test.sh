#!/bin/sh

set -eu

FLAKE_DIR="$(cd "$(dirname "$0")/../nix" && pwd)"

echo "=== Running nix flake check ==="
nix flake check "$FLAKE_DIR" --no-build

if [ "$(uname -s)" = "Darwin" ]; then
  echo ""
  echo "=== Dry-run nix-darwin configuration build ==="
  nix build "$FLAKE_DIR#darwinConfigurations.mac.system" --dry-run
else
  echo ""
  echo "=== Dry-run home-manager build ==="
  nix build "$FLAKE_DIR#homeConfigurations.mikinovation.activationPackage" --dry-run

  echo ""
  echo "=== Dry-run NixOS configuration build ==="
  nix build "$FLAKE_DIR#nixosConfigurations.nixos.config.system.build.toplevel" --dry-run

  # Evaluation is cross-platform, so the darwin configuration can be checked
  # for eval-time breakage without a macOS machine.
  echo ""
  echo "=== Eval nix-darwin configuration ==="
  nix eval "$FLAKE_DIR#darwinConfigurations.mac.system.drvPath" --raw > /dev/null
  echo "OK"
fi

echo ""
echo "All Nix checks passed."
