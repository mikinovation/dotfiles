local vimRails = {}

function vimRails.config()
	return {
		"tpope/vim-rails",
		-- renovate: datasource=github-releases depName=tpope/vim-rails
		version = "5.3",
	}
end

return vimRails
