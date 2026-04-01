local rest = {}

function rest.config()
	return {
		"rest-nvim/rest.nvim",
		-- renovate: datasource=git-refs depName=https://github.com/rest-nvim/rest.nvim
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			local ts = require("nvim-treesitter")
			local installed = ts.get_installed()
			if not vim.list_contains(installed, "http") then
				ts.install({ "http" })
			end
			require("plugins.rest.keymaps").setup()
		end,
	}
end

return rest
