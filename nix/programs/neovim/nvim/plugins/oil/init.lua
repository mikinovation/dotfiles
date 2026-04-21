local oil = {}

function oil.config()
	return {
		"stevearc/oil.nvim",
		dependencies = {
			require("plugins.nvim-web-devicons").config(),
		},
		config = function()
			require("oil").setup({})
			require("plugins.oil.keymaps").setup()
		end,
	}
end

return oil
