-- luacheck: globals vim

-- Change to absolute path instead of the default relative path
package.path = package.path .. ";" .. vim.fn.expand("~/.config/nvim") .. "/?.lua"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

require("options")
require("plugins")
require("keymaps")

-- Create user command for lazydocker
vim.api.nvim_create_user_command("Lazydocker", function()
	require("tools.lazydocker").toggle_lazydocker()
end, {})
