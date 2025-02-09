local cmpPath = {}

function cmpPath.config()
	return {
		"hrsh7th/cmp-path",
		config = function()
			require("cmp").setup({
				sources = {
					{ name = "path" },
				},
			})
		end,
	}
end

return cmpPath
