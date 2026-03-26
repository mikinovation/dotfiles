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
					require("none-ls.diagnostics.eslint_d"),
					require("none-ls.formatting.eslint_d"),
					require("none-ls.code_actions.eslint_d"),
					null_ls.builtins.formatting.rustfmt,
					null_ls.builtins.diagnostics.stylelint.with({
						filetypes = { "css", "scss", "vue" },
					}),
					null_ls.builtins.formatting.stylelint.with({
						filetypes = { "css", "scss", "vue" },
					}),
				},
				debug = false,
			})
		end,
	}
end

return noneLs
