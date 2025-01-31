local noneLs = {}

--[[ local async_formatting = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	vim.lsp.buf_request(
		bufnr,
		"textDocument/formatting",
		vim.lsp.util.make_formatting_params({}),
		function(err, res, ctx)
			if err then
				local err_msg = type(err) == "string" and err or err.message
				vim.notify("formatting: " .. err_msg, vim.log.levels.WARN)
				return
			end

			if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, "modified") then
				return
			end

			if res then
				local client = vim.lsp.get_client_by_id(ctx.client_id)
				vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or "utf-16")
				vim.api.nvim_buf_call(bufnr, function()
					vim.cmd("silent noautocmd update")
				end)
			end
		end
	)
end ]]

function noneLs.config()
	return {
		"nvimtools/none-ls.nvim",
		dependencies = { "nvimtools/none-ls-extras.nvim" },
		config = function()
			local null_ls = require("null-ls")
			local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			null_ls.setup({
				sources = {
					-- lua
					-- null_ls.builtins.diagnostics.stylua,
					-- null_ls.builtins.formatting.stylua,
					-- rust
					-- null_ls.builtins.diagnostics.ltrs,
					-- null_ls.builtins.formatting.ltrs,
					-- stylelint
					null_ls.builtins.diagnostics.stylelint.with({
						filetypes = { "css", "scss", "vue" },
					}),
					null_ls.builtins.formatting.stylelint.with({
						filetypes = { "css", "scss", "vue" },
					}),
					-- javascript
					require("none-ls.diagnostics.eslint_d"),
					require("none-ls.formatting.eslint_d"),
				},
				debug = false,
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePost", {
							group = augroup,
							buffer = bufnr,
							callback = function()
							--	async_formatting(bufnr)
							end,
						})
					end
				end,
			})
		end,
	}
end

return noneLs
