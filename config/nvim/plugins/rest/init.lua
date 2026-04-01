local rest = {}

function rest.config()
	return {
		"rest-nvim/rest.nvim",
		-- renovate: datasource=git-refs depName=https://github.com/rest-nvim/rest.nvim
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("plugins.rest.keymaps").setup()
		end,
	}
end

return rest
