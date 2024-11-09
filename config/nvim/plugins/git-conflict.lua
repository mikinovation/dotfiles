local gitConflict = {}

function gitConflict.config()
	return {
		"akinsho/git-conflict.nvim",
		version = "2.0.0",
		config = function()
			require("git-conflict").setup({
				default_mappings = false,
			})

			vim.keymap.set("n", "<leader>co", "<Plug>(git-conflict-ours)", { desc = "git conflict choose ours" })
			vim.keymap.set("n", "<leader>ct", "<Plug>(git-conflict-theirs)", { desc = "git conflict choose theirs" })
			vim.keymap.set("n", "<leader>cb", "<Plug>(git-conflict-both)", { desc = "git conflict choose both" })
			vim.keymap.set("n", "<leader>cn", "<Plug>(git-conflict-next)", { desc = "git conflict next" })
			vim.keymap.set("n", "<leader>cp", "<Plug>(git-conflict-prev)", { desc = "git conflict prev" })
			vim.keymap.set("n", "<leader>cl", ":GitConflictListQf<CR>", { desc = "git conflict list" })
		end,
	}
end

return gitConflict
