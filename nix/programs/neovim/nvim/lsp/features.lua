-- lsp/features.lua
-- Buffer-local LSP feature toggles that depend on server capabilities.
-- Keymaps live in lsp/keymaps.lua; this file is for non-keymap LSP behavior.

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspFeatures", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if not client then
			return
		end

		-- Keep start/end tags in sync while editing (e.g. HTML, Vue templates).
		if client:supports_method("textDocument/linkedEditingRange") then
			vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
		end

		-- Prefer LSP folding over treesitter folding when the server supports it.
		-- See :h vim.lsp.foldexpr() for the fallback pattern this mirrors.
		if client:supports_method("textDocument/foldingRange") then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end
	end,
})
