local nvimTreesitterContext = {}

function nvimTreesitterContext.config()
	return {
		"nvim-treesitter/nvim-treesitter-context",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("treesitter-context").setup()
		end,
	}
end

return nvimTreesitterContext
