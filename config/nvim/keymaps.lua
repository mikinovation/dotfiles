local keymap = vim.keymap.set

-- keymap(mode, lhs, rhs, opts?)("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Open diagnostics in loclist" })
keymap("n", "<leader>df", vim.diagnostic.open_float, { desc = "Open diagnostics in float" })
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- jjでノーマルモードに戻る
keymap("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Toggleterm
-- ターミナルを開く
keymap("n", "<leader>tt", ":ToggleTerm<CR>", { desc = "Toggle terminal" })

-- Neotest
keymap("n", "<leader>tn", ":lua require('neotest').run.run({strategy = 'dap'})<CR>", { desc = "Run test nearest" })
keymap("n", "<leader>tf", ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>", { desc = "Run test file" })
