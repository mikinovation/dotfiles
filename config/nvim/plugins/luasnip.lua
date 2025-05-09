local luasnip = {}

function luasnip.config()
	return {
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
	}
end

return luasnip
