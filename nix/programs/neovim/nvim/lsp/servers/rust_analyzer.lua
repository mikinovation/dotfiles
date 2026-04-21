-- lsp/servers/rust_analyzer.lua

return function(capabilities)
	vim.lsp.config.rust_analyzer = {
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", ".git" },
		capabilities = capabilities,
		settings = {
			["rust-analyzer"] = {
				checkOnSave = {
					command = "clippy",
				},
			},
		},
	}
end
