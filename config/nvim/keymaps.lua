local keymap = vim.keymap.set

-- keymap(mode, lhs, rhs, opts?)("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Toggleterm
-- ターミナルを開く
keymap("n", "<leader>T", ":ToggleTerm<CR>", { desc = "Toggle terminal" })

-- jjでノーマルモードに戻る
keymap("i", "jj", "<Esc>", { noremap = true, silent = true })
