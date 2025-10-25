-- lsp.lua

-- Keybinding settings for LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		local bufnr = event.buf

		-- Enable completion triggered by <c-x><c-o>
		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer-local keymappings
		local map = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
		end

		-- Keymappings for commonly used features
		map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
		map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
		map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
		map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
		map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
		map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
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

-- LSP diagnostic display settings (signs, floating windows, etc.)
vim.diagnostic.config({
	virtual_text = {
		prefix = "●", -- Customize icon
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

-- Customizing diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- capabilities - integration with nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- LSP server configuration using vim.lsp.config

-- Lua
vim.lsp.config.lua_ls = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
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
}

-- Rust
vim.lsp.config.rust_analyzer = {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	root_markers = { "Cargo.toml", ".git" },
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			checkOnSave = {
				command = "clippy",
			},
		},
	},
}

-- TypeScript/JavaScript
vim.lsp.config.ts_ls = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = {
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
		"vue",
	},
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	capabilities = capabilities,
	init_options = {
		plugins = {
			{
				name = "@vue/typescript-plugin",
				location = "/home/mikinovation/.local/share/fnm/node-versions/v22.13.0/installation/lib/"
					.. "node_modules/@vue/typescript-plugin",
				languages = { "javascript", "typescript", "vue" },
			},
		},
	},
}

-- Vue (Volar)
vim.lsp.config.volar = {
	cmd = { "vue-language-server", "--stdio" },
	filetypes = { "vue" },
	root_markers = { "package.json", ".git" },
	capabilities = capabilities,
}

-- TailwindCSS
vim.lsp.config.tailwindcss = {
	cmd = { "tailwindcss-language-server", "--stdio" },
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
	root_markers = { "tailwind.config.js", "tailwind.config.ts", ".git" },
	capabilities = capabilities,
}

-- Ruby (Solargraph)
vim.lsp.config.solargraph = {
	cmd = { "solargraph", "stdio" },
	filetypes = { "ruby" },
	root_markers = { "Gemfile", ".git" },
	capabilities = capabilities,
	settings = {
		solargraph = {
			diagnostics = true,
			completion = true,
			hover = true,
			formatting = true,
			symbols = true,
			definitions = true,
			rename = true,
			references = true,
		},
	},
}

-- Enable all configured LSP servers
vim.lsp.enable({ "lua_ls", "rust_analyzer", "ts_ls", "volar", "tailwindcss", "solargraph" })
