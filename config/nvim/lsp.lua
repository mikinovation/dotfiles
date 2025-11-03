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

local vue_language_server_path = vim.env.HOME .. "/.nix-profile/lib/node_modules/@vue/language-server"
local tsserver_filetypes = {
	"typescript",
	"javascript",
	"javascriptreact",
	"typescriptreact",
	"vue",
}
local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "vue" },
	configNamespace = "typescript",
}
local vtsls_config = {
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					vue_plugin,
				},
			},
		},
	},
	filetypes = tsserver_filetypes,
}

local ts_ls_config = {
	init_options = {
		plugins = {
			vue_plugin,
		},
	},
	filetypes = tsserver_filetypes,
}

local vue_ls_config = {
	on_init = function(client)
		client.handlers["tsserver/request"] = function(_, result, context)
			local ts_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "ts_ls" })
			local vtsls_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
			local clients = {}

			vim.list_extend(clients, ts_clients)
			vim.list_extend(clients, vtsls_clients)

			if #clients == 0 then
				vim.notify(
					"Could not find `vtsls` or `ts_ls` lsp client, `vue_ls` would not work without it.",
					vim.log.levels.ERROR
				)
				return
			end
			local ts_client = clients[1]

			local param = unpack(result)
			local id, command, payload = unpack(param)
			ts_client:exec_cmd({
				-- Title used to represent a command in the UI, `:h Client:exec_cmd`
				title = "vue_request_forward",
				command = "typescript.tsserverRequest",
				arguments = {
					command,
					payload,
				},
			}, { bufnr = context.bufnr }, function(_, r)
				local response = r and r.body
				-- TODO: handle error or response nil here, e.g. logging
				-- NOTE: Do NOT return if there's an error or no response, just return nil back to the vue_ls to prevent memory leak
				local response_data = { { id, response } }

				---@diagnostic disable-next-line: param-type-mismatch
				client:notify("tsserver/response", response_data)
			end)
		end
	end,
}

-- vtsls (TypeScript/JavaScript LSP)
vim.lsp.config.vtsls = vim.tbl_deep_extend("force", {
	cmd = { "vtsls", "--stdio" },
	filetypes = tsserver_filetypes,
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	capabilities = capabilities,
}, vtsls_config)

-- Vue Language Server
vim.lsp.config.vue_ls = vim.tbl_deep_extend("force", {
	cmd = { "vue-language-server", "--stdio" },
	filetypes = { "vue" },
	root_markers = { "package.json", ".git" },
	capabilities = capabilities,
}, vue_ls_config)

-- TypeScript Language Server (fallback)
vim.lsp.config.ts_ls = vim.tbl_deep_extend("force", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = tsserver_filetypes,
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	capabilities = capabilities,
}, ts_ls_config)

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
vim.lsp.enable({ "lua_ls", "rust_analyzer", "vtsls", "vue_ls", "tailwindcss", "solargraph" })
