-- lsp/servers/nil_ls.lua

return function(capabilities)
	vim.lsp.config.nil_ls = {
		cmd = { "nil" },
		filetypes = { "nix" },
		root_markers = { "flake.nix", "default.nix", "shell.nix", ".git" },
		capabilities = capabilities,
		settings = {
			["nil"] = {
				formatting = {
					command = { "nixfmt" },
				},
				nix = {
					flake = {
						autoArchive = true,
						autoEvalInputs = true,
					},
				},
			},
		},
	}
end
