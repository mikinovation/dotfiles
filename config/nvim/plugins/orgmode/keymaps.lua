local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>or", "<cmd>edit ~/projects/org/refile.org<CR>", { desc = "Open refile.org" })
end

return M
