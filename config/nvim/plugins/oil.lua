local oil = {}

function oil.config()
	return {
		"stevearc/oil.nvim",
		dependencies = {
			require("plugins.nvim-web-devicons").config(),
		},
		config = function()
			require("oil").setup({})

			vim.keymap.set("n", "<leader>fo", require("oil").open, { desc = "Open parent directory" })
		end,
	}
end

return oil
