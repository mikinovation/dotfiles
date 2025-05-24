local luasnip = {}

function luasnip.config()
	return {
		"L3MON4D3/LuaSnip",
		commit = "03c8e67eb7293c404845b3982db895d59c0d1538",
		build = "make install_jsregexp",
		dependencies = {
			require("plugins.friendly-snippets").config(),
		},
	}
end

return luasnip
