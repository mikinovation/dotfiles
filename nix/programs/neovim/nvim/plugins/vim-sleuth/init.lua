local vimSleuth = {}

function vimSleuth.config()
	return {
		"tpope/vim-sleuth",
		event = { "BufReadPost", "BufNewFile" },
	}
end

return vimSleuth
