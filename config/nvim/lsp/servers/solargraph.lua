-- lsp/servers/solargraph.lua

return function(capabilities)
	vim.lsp.config.solargraph = {
		cmd = { "solargraph", "stdio" },
		filetypes = { "ruby" },
		root_markers = { "Gemfile", ".git" },
		capabilities = capabilities,
		settings = {
			solargraph = {
				diagnostics = true,
				completion = true,
				hover = true,
				formatting = true,
				symbols = true,
				definitions = true,
				rename = true,
				references = true,
			},
		},
	}
end
