local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>tt", ":ToggleTerm<CR>", { desc = "Toggle terminal" })
end

return M
