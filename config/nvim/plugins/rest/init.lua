local rest = {}

function rest.config()
	return {
		"rest-nvim/rest.nvim",
		-- renovate: datasource=git-refs depName=https://github.com/rest-nvim/rest.nvim
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			opts = function(_, opts)
				opts.ensure_installed = opts.ensure_installed or {}
				table.insert(opts.ensure_installed, "http")
			end,
		},
		opts = {
			rocks = {
				enabled = false,
			},
		},
		config = function()
			require("plugins.rest.keymaps").setup()
		end,
	}
end

return rest
