local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>co", "<Plug>(git-conflict-ours)", { desc = "git conflict choose ours" })
	vim.keymap.set("n", "<leader>ct", "<Plug>(git-conflict-theirs)", { desc = "git conflict choose theirs" })
	vim.keymap.set("n", "<leader>cb", "<Plug>(git-conflict-both)", { desc = "git conflict choose both" })
	vim.keymap.set("n", "<leader>cn", "<Plug>(git-conflict-next)", { desc = "git conflict next" })
	vim.keymap.set("n", "<leader>cp", "<Plug>(git-conflict-prev)", { desc = "git conflict prev" })
	vim.keymap.set("n", "<leader>cl", ":GitConflictListQf<CR>", { desc = "git conflict list" })
end

return M
