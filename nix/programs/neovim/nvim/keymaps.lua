-- keymaps.lua
-- Global keymaps. This file contains only key bindings.
-- All non-trivial logic lives in actions.lua (or other modules).

local actions = require("actions")
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Open diagnostics in loclist" })
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Open diagnostics in float" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

map("n", "<leader>rm", ":%s/\r//g<CR>", { desc = "Remove ^M" })

map("i", "jj", "<Esc>", { noremap = true, silent = true })

map("n", "<leader>fm", actions.format_document, { desc = "Format document" })
map("n", "<leader>fe", actions.open_in_explorer, { desc = "Open in Windows Explorer" })
map("n", "<leader>ld", actions.toggle_lazydocker, { desc = "Toggle lazydocker" })
