-- lsp/servers/tailwindcss.lua

return function(capabilities)
	vim.lsp.config.tailwindcss = {
		cmd = { "tailwindcss-language-server", "--stdio" },
		filetypes = {
			"html",
			"css",
			"scss",
			"javascript",
			"typescript",
			"javascriptreact",
			"typescriptreact",
			"vue",
		},
		root_markers = { "tailwind.config.js", "tailwind.config.ts", ".git" },
		capabilities = capabilities,
	}
end
