-- lsp/servers/lua_ls.lua

return function(capabilities)
	vim.lsp.config.lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
		capabilities = capabilities,
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim", "use" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
					checkThirdParty = false,
				},
				telemetry = {
					enable = false,
				},
				completion = {
					callSnippet = "Replace",
				},
			},
		},
	}
end
