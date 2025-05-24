local yanky = {}

function yanky.config()
	return {
		"gbprod/yanky.nvim",
		commit = "04775cc6e10ef038c397c407bc17f00a2f52b378",
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
