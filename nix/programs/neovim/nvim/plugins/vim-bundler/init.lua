local vimBundler = {}

function vimBundler.config()
	return {
		"tpope/vim-bundler",
		ft = { "ruby", "eruby" },
	}
end

return vimBundler
