-- luacheck: globals vim

-- Change to absolute path instead of the default relative path
local config_path = vim.fn.stdpath("config")
package.path = package.path .. ";" .. config_path .. "/?.lua;" .. config_path .. "/?/init.lua"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

require("options")
require("plugins")
require("lsp")
require("keymaps")

-- Create user command for lazydocker
vim.api.nvim_create_user_command("Lazydocker", require("actions").toggle_lazydocker, {})

-- Create user commands for difit (Git diff web UI)
vim.api.nvim_create_user_command("Difit", require("actions").open_difit, {})
vim.api.nvim_create_user_command("DifitStop", require("actions").stop_difit, {})
