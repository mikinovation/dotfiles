local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "[M]arkdown [P]review" })
end

return M
