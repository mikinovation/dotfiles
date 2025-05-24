local nvimTreesitterContext = {}

function nvimTreesitterContext.config()
	return {
		"nvim-treesitter/nvim-treesitter-context",
		commit = "93b29a32d5f4be10e39226c6b796f28d68a8b483",
		config = function()
			require("treesitter-context").setup()
		end,
	}
end

return nvimTreesitterContext
