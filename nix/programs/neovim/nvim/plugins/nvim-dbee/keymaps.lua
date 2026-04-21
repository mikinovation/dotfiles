local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>db", "<cmd>Dbee toggle<CR>", { desc = "Toggle DBee" })
end

return M
