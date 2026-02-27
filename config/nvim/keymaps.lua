local keymap = vim.keymap.set

keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Open diagnostics in loclist" })
keymap("n", "<leader>df", vim.diagnostic.open_float, { desc = "Open diagnostics in float" })
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

keymap("n", "<leader>rm", ":%s/\r//g<CR>", { desc = "Remove ^M" })

keymap("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Format with LSP/null-ls (ESLint, etc.)
keymap("n", "<leader>fm", function()
	vim.lsp.buf.format({ async = true })
end, { desc = "Format document" })

-- Open current file's directory in Windows Explorer
keymap("n", "<leader>fe", function()
	local dir = vim.fn.expand("%:p:h")
	local win_dir = vim.fn.system({ "wslpath", "-w", dir }):gsub("\n", "")
	vim.fn.system({ "explorer.exe", win_dir })
end, { desc = "Open in Windows Explorer" })

-- Lazydocker integration
keymap("n", "<leader>ld", function()
	require("tools.lazydocker").toggle_lazydocker()
end, { desc = "Toggle lazydocker" })
