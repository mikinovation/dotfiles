-- plugins/none-ls.lua
local noneLs = {}

function noneLs.config()
	return {
		"nvimtools/none-ls.nvim",
		dependencies = {
			require("plugins.none-ls-extras").config(),
			require("plugins.plenary").config(),
		},
		config = function()
			local null_ls = require("null-ls")

			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.stylua,
					require("none-ls.formatting.eslint_d"),
					null_ls.builtins.formatting.rustfmt,
					null_ls.builtins.diagnostics.eslint_d,
					null_ls.builtins.diagnostics.stylelint.with({
						filetypes = { "css", "scss", "vue" },
					}),

					null_ls.builtins.code_actions.eslint_d,
				},

				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({
									bufnr = bufnr,
									filter = function(lsp_client)
										return lsp_client.name == "null-ls"
									end,
								})
							end,
						})

						vim.keymap.set("n", "<leader>nf", function()
							vim.lsp.buf.format({
								bufnr = bufnr,
								filter = function(lsp_client)
									return lsp_client.name == "null-ls"
								end,
							})
						end, { buffer = bufnr, desc = "Format current buffer with none-ls" })
					end
				end,
			})
		end,
	}
end

return noneLs
