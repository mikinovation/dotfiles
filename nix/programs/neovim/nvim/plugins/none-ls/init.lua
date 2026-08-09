-- plugins/none-ls.lua
local noneLs = {}

function noneLs.config()
	return {
		"nvimtools/none-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			require("plugins.none-ls-extras").config(),
			require("plugins.plenary").config(),
		},
		config = function()
			local null_ls = require("null-ls")

			-- stylua ships with the Nix profile, so it is always available.
			local sources = { null_ls.builtins.formatting.stylua }

			-- The remaining sources shell out to a command that is not part of
			-- this profile. Registering one that is missing makes null-ls raise
			-- "command <x> is not executable" on every matching buffer, so each
			-- group is only added when its command is on $PATH.
			if vim.fn.executable("eslint_d") == 1 then
				vim.list_extend(sources, {
					require("none-ls.diagnostics.eslint_d"),
					require("none-ls.formatting.eslint_d"),
					require("none-ls.code_actions.eslint_d"),
				})
			end

			if vim.fn.executable("rustfmt") == 1 then
				-- rustfmt was moved out of none-ls builtins into none-ls-extras
				table.insert(sources, require("none-ls.formatting.rustfmt"))
			end

			if vim.fn.executable("stylelint") == 1 then
				vim.list_extend(sources, {
					null_ls.builtins.diagnostics.stylelint.with({
						filetypes = { "css", "scss", "vue" },
					}),
					null_ls.builtins.formatting.stylelint.with({
						filetypes = { "css", "scss", "vue" },
					}),
				})
			end

			null_ls.setup({
				sources = sources,
				debug = false,
			})
		end,
	}
end

return noneLs
