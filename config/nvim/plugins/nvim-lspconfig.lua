-- plugins/nvim-lspconfig.lua
local nvimLspconfig = {}

function nvimLspconfig.config()
	return {
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
			"folke/neodev.nvim", -- Lua用の開発サポート
		},
		config = function()
			-- neodevを先に設定（lua_lsの設定より前に）
			require("neodev").setup({})

			-- LSPアタッチ時のキーバインド設定
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					local bufnr = event.buf

					-- Enable completion triggered by <c-x><c-o>
					vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

					-- バッファローカルなキーマッピング
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
					end

					-- よく使う機能のキーマッピング
					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
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

			-- LSPの診断表示設定（サイン、floating windowなど）
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●", -- アイコンをカスタマイズ
					severity = {
						min = vim.diagnostic.severity.WARN,
					},
				},
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = {
					focusable = false,
					style = "minimal",
					border = "rounded",
					source = "always",
				},
			})

			-- diagnosticサインのカスタマイズ
			local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
			for type, icon in pairs(signs) do
				local hl = "DiagnosticSign" .. type
				vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
			end

			-- capabilities - nvim-cmpとの連携
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			-- LSPサーバーの設定
			local lspconfig = require("lspconfig")

			-- Lua
			lspconfig.lua_ls.setup({
				capabilities = capabilities,
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim", "use" },
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = {
							enable = false,
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			})

			-- Ruby
			lspconfig.solargraph.setup({
				capabilities = capabilities,
				cmd = { "solargraph", "stdio" },
				filetypes = { "ruby" },
				root_dir = lspconfig.util.root_pattern("Gemfile", ".git"),
				settings = {
					solargraph = {
						diagnostics = true,
					},
				},
			})

			-- Rust
			lspconfig.rust_analyzer.setup({
				capabilities = capabilities,
				filetypes = { "rust" },
				root_dir = lspconfig.util.root_pattern("Cargo.toml"),
				settings = {
					["rust-analyzer"] = {
						checkOnSave = {
							command = "clippy",
						},
					},
				},
			})

			-- TypeScript/JavaScript
			lspconfig.ts_ls.setup({
				capabilities = capabilities,
				filetypes = {
					"typescript",
					"javascript",
					"javascriptreact",
					"typescriptreact",
				},
			})

			-- Vue
			lspconfig.volar.setup({
				capabilities = capabilities,
				filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
				init_options = {
					vue = {
						hybridMode = false,
					},
				},
			})

			-- TailwindCSS
			lspconfig.tailwindcss.setup({
				capabilities = capabilities,
				filetypes = {
					"html",
					"css",
					"scss",
					"javascript",
					"typescript",
					"javascriptreact",
					"typescriptreact",
					"vue",
				},
			})
		end,
	}
end

return nvimLspconfig
