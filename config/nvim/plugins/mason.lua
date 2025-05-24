local mason = {}

function mason.config()
	return {
		"williamboman/mason.nvim",
		commit = "fc98833b6da5de5a9c5b1446ac541577059555be",
		dependencies = {
			require("plugins.mason-lspconfig").config(),
			require("plugins.nvim-lspconfig").config(),
		},
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"ts_ls",
					"volar",
					"tailwindcss",
				},
				automatic_installation = true,
			})
		end,
	}
end

return mason
