local cmpPath = {}

function cmpPath.config()
	return {
		"hrsh7th/nvim-cmp",
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
