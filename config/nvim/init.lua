-- luacheck: globals vim

-- デフォルトだと相対パスになってしまうので、絶対パスに変更
package.path = package.path .. ";" .. vim.fn.expand("~/.config/nvim") .. "/?.lua"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

require("options")

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

require("plugins")
require("keymaps")

-- Vimを起動したときにNeotreeを開く
vim.cmd([[autocmd VimEnter * Neotree]])
