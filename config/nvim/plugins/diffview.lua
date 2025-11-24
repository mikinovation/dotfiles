local diffview = {}

function diffview.config()
	return {
		"sindrets/diffview.nvim",
		config = function()
			require("diffview").setup({})

			vim.keymap.set("n", "<leader>dvo", "<cmd>DiffviewOpen<CR>", { desc = "Diffview Open" })
			vim.keymap.set("n", "<leader>dvh", "<cmd>DiffviewFileHistory<CR>", { desc = "Diffview File History" })
			vim.keymap.set(
				"n",
				"<leader>dvf",
				"<cmd>DiffviewFileHistory %<CR>",
				{ desc = "Diffview Current File History" }
			)
		end,
	}
end

return diffview
