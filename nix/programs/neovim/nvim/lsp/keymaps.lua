-- lsp/keymaps.lua
-- Buffer-local LSP keymaps. This file contains only key bindings.
-- All non-trivial logic lives in lsp/actions.lua (or other modules).

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local bufnr = event.buf
		local builtin = require("telescope.builtin")
		local actions = require("lsp.actions")

		-- Buffer-local keymappings
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
		end

		map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
		map("gr", builtin.lsp_references, "[G]oto [R]eferences")
		map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
		map("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
		map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
		map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
		map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- Diagnostics
		map("<leader>e", vim.diagnostic.open_float, "Open [E]rror")
		map("<leader>q", vim.diagnostic.setloclist, "Diagnostics to [L]ocation List")

		-- Format document (only when supported by the attached client)
		if client and client:supports_method("textDocument/formatting") then
			map("<leader>f", actions.format_document, "[F]ormat document")
		end
	end,
})
