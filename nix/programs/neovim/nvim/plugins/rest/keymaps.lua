local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>hr", "<cmd>Rest run<CR>", { desc = "Run REST request" })
end

return M
