local nvimColorizer = {}

function nvimColorizer.config()
	return {
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup()
		end,
	}
end

return nvimColorizer
