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
require("ime").setup()

-- Create user command for lazydocker
vim.api.nvim_create_user_command("Lazydocker", function()
	require("tools.lazydocker").toggle_lazydocker()
end, {})
