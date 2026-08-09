local tsc = {}

function tsc.config()
	return {
		"dmmulroy/tsc.nvim",
		cmd = { "TSC", "TSCOpen", "TSCClose", "TSCStop" },
		config = function()
			require("tsc").setup({})
		end,
	}
end

return tsc
