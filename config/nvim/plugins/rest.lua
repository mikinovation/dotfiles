local rest = {}

function rest.config()
	return {
		"rest-nvim/rest.nvim",
		commit = "2ded89dbda1fd3c1430685ffadf2df8beb28336d",
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
