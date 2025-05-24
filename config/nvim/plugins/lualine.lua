local lualine = {}

function lualine.config()
	return {
		"nvim-lualine/lualine.nvim",
		commit = "15884cee63a8c205334ab13ab1c891cd4d27101a",
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
