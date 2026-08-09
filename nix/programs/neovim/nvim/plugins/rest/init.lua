local rest = {}

function rest.config()
	return {
		"rest-nvim/rest.nvim",
		-- renovate: datasource=git-refs depName=https://github.com/rest-nvim/rest.nvim
		ft = "http",
		cmd = "Rest",
		-- Keep in sync with plugins/rest/keymaps.lua
		keys = {
			{ "<leader>hr", desc = "Run REST request" },
		},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("plugins.rest.keymaps").setup()
		end,
	}
end

return rest
