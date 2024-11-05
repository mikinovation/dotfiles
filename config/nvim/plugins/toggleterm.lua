local toggleterm = {}

function toggleterm.config()
	return {
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				direction = "vertical",
				size = 80,
				start_in_insert = true,
			})
		end,
	}
end

return toggleterm
