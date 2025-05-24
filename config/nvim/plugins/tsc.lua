local tsc = {}

function tsc.config()
	return {
		"dmmulroy/tsc.nvim",
		commit = "5bd25bb5c399b6dc5c00392ade6ac6198534b53a",
		config = function()
			require("tsc").setup({})
		end,
	}
end

return tsc
