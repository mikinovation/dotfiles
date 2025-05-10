local rest = {}

function rest.config()
	return {
		"rest-nvim/rest.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			opts = function(_, opts)
				opts.ensure_installed = opts.ensure_installed or {}
				table.insert(opts.ensure_installed, "http")
			end,
		},
		config = function()
			vim.keymap.set("n", "<leader>rr", "<Plug>RestNvim", { desc = "Run HTTP request under cursor" })
			vim.keymap.set("n", "<leader>rp", "<Plug>RestNvimPreview", { desc = "Preview HTTP request under cursor" })
			vim.keymap.set("n", "<leader>rl", "<Plug>RestNvimLast", { desc = "Re-run last HTTP request" })
		end,
	}
end

return rest
