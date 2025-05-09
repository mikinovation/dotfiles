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
