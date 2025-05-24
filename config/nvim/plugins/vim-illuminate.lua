local vimIlluminate = {}

function vimIlluminate.config()
	return {
		"RRethy/vim-illuminate",
		commit = "fbc16dee336d8cc0d3d2382ea4a53f4a29725abf",
		config = function()
			require("illuminate").configure()
		end,
	}
end

return vimIlluminate
