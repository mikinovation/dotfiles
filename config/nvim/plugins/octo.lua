local octo = {}

function octo.config()
	return {
		"pwntester/octo.nvim",
		dependencies = {
			require("plugins.plenary").config(),
			require("plugins.telescope").config(),
			require("plugins.nvim-web-devicons").config(),
		},
		config = function()
			require("octo").setup({})
		end,
	}
end

return octo
