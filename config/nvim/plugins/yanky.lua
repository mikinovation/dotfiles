local yanky = {}

function yanky.config()
	return {
		"gbprod/yanky.nvim",
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
