local nvimColorizer = {}

function nvimColorizer.config()
	return {
		"norcalli/nvim-colorizer.lua",
		commit = "a065833f35a3a7cc3ef137ac88b5381da2ba302e",
		config = function()
			require("colorizer").setup()
		end,
	}
end

return nvimColorizer
