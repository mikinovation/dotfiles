local toggleterm = {}

function toggleterm.config()
	return {
		"akinsho/toggleterm.nvim",
		commit = "50ea089fc548917cc3cc16b46a8211833b9e3c7c",
		version = "*",
		config = function()
			require("toggleterm").setup({
				direction = "float",
				size = 80,
				start_in_insert = true,
				float_opts = {
					border = "curved",
					winblend = 0,
				},
			})

			vim.keymap.set("n", "<leader>tt", ":ToggleTerm<CR>", { desc = "Toggle terminal" })
		end,
	}
end

return toggleterm
