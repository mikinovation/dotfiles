local neoTree = {}

function neoTree.config()
	return {
		"nvim-neo-tree/neo-tree.nvim",
		dependencies = {
			require("plugins.plenary").config(),
			require("plugins.nvim-web-devicons").config(),
			require("plugins.nui").config(),
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		opts = {
			filesystem = {
				filtered_items = { visible = true, hide_dotfiles = false },
			},
		},
		config = function()
			vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file explorer" })
		end,
	}
end

return neoTree
