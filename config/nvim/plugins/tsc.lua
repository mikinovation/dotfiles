local tsc = {}

function tsc.config()
	return {
		"dmmulroy/tsc.nvim",
		config = function()
			require("tsc").setup({})
		end,
	}
end

return tsc
