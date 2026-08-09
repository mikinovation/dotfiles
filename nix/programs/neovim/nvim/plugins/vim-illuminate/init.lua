local vimIlluminate = {}

function vimIlluminate.config()
	return {
		"RRethy/vim-illuminate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("illuminate").configure()
		end,
	}
end

return vimIlluminate
