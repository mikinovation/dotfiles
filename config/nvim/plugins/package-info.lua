local packageInfo = {}

function packageInfo.config()
	return {
		"vuki656/package-info.nvim",
		dependencies = {
			require("plugins.nui").config(),
		},
		config = function()
			require("package-info").setup()

			vim.api.nvim_set_keymap(
				"n",
				"<leader>ns",
				"<cmd>lua require('package-info').show()<CR>",
				{ noremap = true, silent = true, desc = "[N]pm [S]how" }
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>nd",
				"<cmd>lua require('package-info').delete()<CR>",
				{ noremap = true, silent = true, desc = "[N]pm [D]elete" }
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>nc",
				"<cmd>lua require('package-info').change_version()<CR>",
				{ noremap = true, silent = true, desc = "[N]pm [C]hange version" }
			)

			vim.api.nvim_set_keymap(
				"n",
				"<leader>ni",
				"<cmd>lua require('package-info').install()<CR>",
				{ noremap = true, silent = true, desc = "[N]pm [I]nstall" }
			)
		end,
	}
end

return packageInfo
