local mason = {}

function mason.config()
	return {
		"williamboman/mason.nvim",
		dependencies = {
			require("plugins/mason-lspconfig").config(),
			require("plugins/nvim-lspconfig").config(),
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
					"solargraph",
					"volar",
					"tailwindcss",
				},
				automatic_installation = true,
			})
		end,
	}
end

return mason
