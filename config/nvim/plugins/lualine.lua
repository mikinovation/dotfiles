local lualine = {}

function lualine.config()
	return {
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			options = {
				icons_enabled = true,
				theme = "nightfly",
			},
		},
	}
end

return lualine
