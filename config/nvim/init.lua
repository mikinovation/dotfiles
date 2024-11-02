-- luacheck: globals vim

-- デフォルトだと相対パスになってしまうので、絶対パスに変更
package.path = package.path .. ";" .. vim.fn.expand("~/.config/nvim") .. "/?.lua"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

require("options")
require("plugins")
require("keymaps")

-- Vimを起動したときにNeotreeを開く
vim.cmd([[autocmd VimEnter * Neotree]])
