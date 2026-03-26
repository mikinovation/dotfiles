-- lsp/servers/typescript.lua
-- TypeScript, JavaScript, Vue related LSP servers (tsgo, vtsls, vue_ls)

return function(capabilities)
	local vue_language_server_path = vim.env.VUE_LANGUAGE_SERVER_PATH
		or (vim.env.HOME .. "/.nix-profile/lib/node_modules/@vue/language-server")
	local vue_plugin = {
		name = "@vue/typescript-plugin",
		location = vue_language_server_path,
		languages = { "vue" },
		configNamespace = "typescript",
	}

	local vue_ls_config = {
		on_init = function(client)
			client.handlers["tsserver/request"] = function(_, result, context)
				local vtsls_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })

				if #vtsls_clients == 0 then
					vim.notify(
						"Could not find `vtsls` lsp client, `vue_ls` would not work without it.",
						vim.log.levels.ERROR
					)
					-- Send nil response to prevent vue_ls from waiting indefinitely
					local param = unpack(result)
					local id = unpack(param)
					---@diagnostic disable-next-line: param-type-mismatch
					client:notify("tsserver/response", { { id, nil } })
					return
				end
				local ts_client = vtsls_clients[1]

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

	-- tsgo (TypeScript Go-based LSP)
	vim.lsp.config.tsgo = {
		cmd = { "tsgo", "--lsp", "--stdio" },
		filetypes = {
			"typescript",
			"javascript",
			"javascriptreact",
			"typescriptreact",
		},
		root_markers = {
			"package-lock.json",
			"yarn.lock",
			"pnpm-lock.yaml",
			"bun.lockb",
			"bun.lock",
			".git",
		},
		capabilities = capabilities,
	}

	-- vtsls (Vue support only - tsserver request forwarding for vue_ls)
	vim.lsp.config.vtsls = vim.tbl_deep_extend("force", {
		cmd = { "vtsls", "--stdio" },
		filetypes = { "vue" },
		root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
		capabilities = capabilities,
	}, {
		settings = {
			vtsls = {
				tsserver = {
					globalPlugins = {
						vue_plugin,
					},
				},
			},
		},
		filetypes = { "vue" },
	})

	-- Vue Language Server
	vim.lsp.config.vue_ls = vim.tbl_deep_extend("force", {
		cmd = { "vue-language-server", "--stdio" },
		filetypes = { "vue" },
		root_markers = { "package.json", ".git" },
		capabilities = capabilities,
	}, vue_ls_config)
end
