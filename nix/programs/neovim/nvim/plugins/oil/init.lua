local oil = {}

function oil.config()
	return {
		"stevearc/oil.nvim",
		cmd = "Oil",
		-- Keep in sync with plugins/oil/keymaps.lua
		keys = {
			{ "<leader>fo", desc = "Open parent directory" },
		},
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
