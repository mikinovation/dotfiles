-- lsp/keymaps.lua

-- Keybinding settings for LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local bufnr = event.buf
		local builtin = require("telescope.builtin")

		-- Enable completion triggered by <c-x><c-o>
		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer-local keymappings
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
		end

		-- Keymappings for commonly used features
		map("gd", builtin.lsp_definitions, "[G]oto [D]efinition")
		map("gr", builtin.lsp_references, "[G]oto [R]eferences")
		map("gI", builtin.lsp_implementations, "[G]oto [I]mplementation")
		map("<leader>D", builtin.lsp_type_definitions, "Type [D]efinition")
		map("<leader>ds", builtin.lsp_document_symbols, "[D]ocument [S]ymbols")
		map("<leader>ws", builtin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
		map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
		map("K", vim.lsp.buf.hover, "Hover Documentation")
		map("<C-k>", vim.lsp.buf.signature_help, "Signature Help")

		-- Diagnostics
		map("<leader>e", vim.diagnostic.open_float, "Open [E]rror")
		map("[d", vim.diagnostic.goto_prev, "Previous [D]iagnostic")
		map("]d", vim.diagnostic.goto_next, "Next [D]iagnostic")
		map("<leader>q", vim.diagnostic.setloclist, "Diagnostics to [Q]uickfix List")

		-- Format document
		if client.supports_method("textDocument/formatting") then
			map("<leader>f", function()
				vim.lsp.buf.format({ async = true })
			end, "[F]ormat document")
		end
	end,
})
