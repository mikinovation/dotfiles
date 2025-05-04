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

			-- Neotest keymaps
			vim.keymap.set(
				"n",
				"<leader>tn",
				":lua require('neotest').run.run({strategy = 'dap'})<CR>",
				{ desc = "Run test nearest" }
			)
			vim.keymap.set(
				"n",
				"<leader>tf",
				":lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
				{ desc = "Run test file" }
			)
		end,
	}
end

return neotest
