local dropbar = {}

function dropbar.config()
	return {
		"Bekaboo/dropbar.nvim",
		-- optional, but required for fuzzy finder support
		dependencies = {
			require("plugins.telescope-fzf-native").config(),
		},
		config = function()
			require("plugins.dropbar.keymaps").setup()
		end,
	}
end

return dropbar
