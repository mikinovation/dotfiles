local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>aw", ":ArgWrap<CR>", { desc = "Argwrap" })
end

return M
