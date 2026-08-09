local yanky = {}

function yanky.config()
	return {
		"gbprod/yanky.nvim",
		event = "VeryLazy",
		opts = {},
		config = function()
			require("yanky").setup({
				highlight = {
					timer = 200,
				},
			})
		end,
	}
end

return yanky
