local nvimTreesitterContext = {}

function nvimTreesitterContext.config()
	return {
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("nvim-treesitter.configs").setup()
		end,
	}
end

return nvimTreesitterContext
