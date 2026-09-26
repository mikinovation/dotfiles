# Task runner for this repository.
# Run `make` or `make help` to list the available targets.

SHELL := /bin/bash
.DEFAULT_GOAL := help

FLAKE_DIR := ./nix
PROFILE ?=

.PHONY: help setup setup-full setup-minimal \
	check lint fmt fmt-fix test \
	nix-check nix-fmt nix-fmt-fix nix-test \
	nvim-smoke-test

help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'

# Setup

setup: ## Deploy dotfiles (PROFILE=full|minimal)
	DOTFILES_PROFILE=$(PROFILE) ./setup.sh

setup-full: ## Deploy dotfiles with the full profile
	DOTFILES_PROFILE=full ./setup.sh

setup-minimal: ## Deploy dotfiles with the minimal profile
	DOTFILES_PROFILE=minimal ./setup.sh

# Lua

check: lint fmt test ## Run lint, format check and tests

lint: ## Run luacheck + secretlint (requires `npm ci`)
	nix run $(FLAKE_DIR)#lint

fmt: ## Check Lua formatting with stylua
	nix run $(FLAKE_DIR)#fmt

fmt-fix: ## Format Lua files with stylua
	nix develop $(FLAKE_DIR) -c stylua .

test: ## Run busted tests
	nix run $(FLAKE_DIR)#test

# Nix

nix-check: nix-fmt nix-test ## Run Nix format check and Nix tests

nix-fmt: ## Check Nix formatting
	sh ./scripts/nix-fmt.sh

nix-fmt-fix: ## Format Nix files
	cd $(FLAKE_DIR) && find . -name '*.nix' -not -path './node2nix/*' -print0 | xargs -0 nix fmt --

nix-test: ## Run nix flake check and dry-run builds
	sh ./scripts/nix-test.sh

# Neovim

nvim-smoke-test: ## Verify Neovim starts without errors
	sh ./scripts/nvim-smoke-test.sh
