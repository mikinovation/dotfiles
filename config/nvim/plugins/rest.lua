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
			vim.keymap.set("n", "<leader>rr", "<cmd>Rest run<CR>", { desc = "Select REST environment file" })
		end,
	}
end

return rest
