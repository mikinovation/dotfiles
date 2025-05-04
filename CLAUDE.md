# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- **Lint:** `sh ./scripts/lint.sh` (uses luacheck for Lua linting)
- **Format:** `sh ./scripts/format.sh` (uses stylua for Lua formatting)
- **Setup:** `./setup.sh` (links configuration files to appropriate locations)

## Code Style Guidelines

- **Formatting:** Use stylua for Lua code formatting
- **Linting:** Use luacheck for Lua code linting
- **Naming:** Use camelCase for variables and functions (e.g., `neoTree.config()`)
- **Structure:** 
  - Organize Neovim plugins into separate files in config/nvim/plugins/
  - Each plugin file should export a table with a config function
  - Use proper indentation (tabs for Lua code)
- **Dependencies:** List plugin dependencies explicitly when configuring
- **Comments:** Include meaningful comments for complex configurations
- **Options:** Use the opts parameter for plugin configuration when available
- **Keymaps:** Set using vim.keymap.set() with descriptive comments

## Git Commit Guidelines

- **Commit Messages:** Follow conventional commits format (e.g., `feat:`, `fix:`, `chore:`)
- **Authorship:** Keep commit messages clean without any AI attribution
- **Pull Requests:** Maintain PR descriptions without AI generation notes or attribution lines
