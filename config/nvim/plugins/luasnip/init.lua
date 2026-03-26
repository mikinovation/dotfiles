local luasnip = {}

function luasnip.config()
	return {
		"L3MON4D3/LuaSnip",
		build = "make install_jsregexp",
		dependencies = {
			require("plugins.friendly-snippets").config(),
		},
	}
end

return luasnip
