local neoscroll = {}

function neoscroll.config()
	return {
		"dmmulroy/neoscroll.nvim",
		config = function()
			require("neoscroll").setup({})
		end,
	}
end

return neoscroll
