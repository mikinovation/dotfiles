local vimMatchup = {}

function vimMatchup.config()
	return {
		"andymass/vim-matchup",
		event = { "BufReadPost", "BufNewFile" },
	}
end

return vimMatchup
