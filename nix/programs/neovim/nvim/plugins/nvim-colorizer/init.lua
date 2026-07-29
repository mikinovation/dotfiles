local nvimColorizer = {}

function nvimColorizer.config()
	return {
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = {
			options = {
				parsers = {
					tailwind = { enable = true, lsp = true },
				},
			},
		},
	}
end

return nvimColorizer
