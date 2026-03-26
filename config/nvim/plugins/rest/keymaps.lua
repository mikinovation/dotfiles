local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>rr", "<cmd>Rest run<CR>", { desc = "Select REST environment file" })
end

return M
