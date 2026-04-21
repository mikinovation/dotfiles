local toggleterm = {}

function toggleterm.config()
	return {
		"akinsho/toggleterm.nvim",
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

			require("plugins.toggleterm.keymaps").setup()
		end,
	}
end

return toggleterm
