local neogit = {}

function neogit.config()
	return {
		"NeogitOrg/neogit",
		dependencies = {
			require("plugins.plenary").config(),
			"sindrets/diffview.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = true,
	}
end

return neogit
