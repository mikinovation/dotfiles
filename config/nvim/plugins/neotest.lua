local neotest = {}

function neotest.config()
	return {
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			require("plugins.plenary").config(),
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"rouge8/neotest-rust",
			"marilari88/neotest-vitest",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-rust"),
					require("neotest-vitest"),
				},
			})
		end,
	}
end

return neotest
