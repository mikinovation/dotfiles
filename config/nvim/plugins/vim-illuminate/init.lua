local vimIlluminate = {}

function vimIlluminate.config()
	return {
		"RRethy/vim-illuminate",
		config = function()
			require("illuminate").configure()
		end,
	}
end

return vimIlluminate
