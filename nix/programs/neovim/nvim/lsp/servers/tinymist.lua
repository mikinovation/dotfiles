-- lsp/servers/tinymist.lua

return function(capabilities)
	vim.lsp.config.tinymist = {
		cmd = { "tinymist" },
		filetypes = { "typst" },
		root_markers = { "typst.toml", ".git" },
		capabilities = capabilities,
		settings = {
			exportPdf = "onSave",
			formatterMode = "typstyle",
			semanticTokens = "enable",
		},
	}
end
