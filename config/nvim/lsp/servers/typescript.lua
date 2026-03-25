-- lsp/servers/typescript.lua
-- TypeScript, JavaScript, Vue related LSP servers (vtsls, ts_ls, vue_ls)

return function(capabilities)
	local vue_language_server_path = vim.env.VUE_LANGUAGE_SERVER_PATH
		or (vim.env.HOME .. "/.nix-profile/lib/node_modules/@vue/language-server")
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
					-- Send nil response to prevent vue_ls from waiting indefinitely
					local param = unpack(result)
					local id = unpack(param)
					---@diagnostic disable-next-line: param-type-mismatch
					client:notify("tsserver/response", { { id, nil } })
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
					-- NOTE: Do NOT return if there's an error or no response,
					-- just return nil back to the vue_ls to prevent memory leak
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
end
