local lualine = {}

function lualine.config()
	return {
		"nvim-lualine/lualine.nvim",
		dependencies = {
			require("plugins.nvim-web-devicons").config(),
		},
		opts = {
			options = {
				icons_enabled = true,
				theme = "nightfly",
			},
		},
	}
end

return lualine
