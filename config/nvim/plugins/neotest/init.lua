local neotest = {}

function neotest.config()
	return {
		"nvim-neotest/neotest",
		dependencies = {
			require("plugins.nvim-nio").config(),
			require("plugins.plenary").config(),
			require("plugins.fixcursorhold").config(),
			require("plugins.nvim-treesitter").config(),
			require("plugins.neotest-rust").config(),
			require("plugins.neotest-vitest").config(),
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-rust"),
					require("neotest-vitest"),
				},
			})

			require("plugins.neotest.keymaps").setup()
		end,
	}
end

return neotest
