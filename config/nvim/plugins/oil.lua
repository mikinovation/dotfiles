local oil = {}

function oil.config()
	return {
		"stevearc/oil.nvim",
		config = function()
			require("oil").setup({})
		end,
	}
end

return oil
