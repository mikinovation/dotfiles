local neoTree = {}

function neoTree.config()
	return {
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			require("plugins.plenary").config(),
			require("plugins.nvim-web-devicons").config(),
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		},
		opts = {
			filesystem = {
				filtered_items = { visible = true, hide_dotfiles = false },
			},
		},
	}
end

return neoTree
