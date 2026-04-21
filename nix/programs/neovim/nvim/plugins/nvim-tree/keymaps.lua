local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
	vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal current file in tree" })
end

return M
