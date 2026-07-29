-- lsp/servers/typescript.lua
-- TypeScript, JavaScript, Vue related LSP servers (vtsls, vue_ls)

return function(capabilities)
	-- tsserver loads @vue/typescript-plugin from <location>/node_modules,
	-- so the path must exist on disk
	local vue_language_server_path = vim.env.VUE_LANGUAGE_SERVER_PATH
	if not vue_language_server_path then
		local bin = vim.fn.exepath("vue-language-server")
		if bin ~= "" then
			vue_language_server_path = vim.fs.dirname(vim.fs.dirname(bin)) .. "/lib/node_modules/@vue/language-server"
		else
			vue_language_server_path = vim.env.HOME .. "/.nix-profile/lib/node_modules/@vue/language-server"
		end
	end
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

	-- vtsls (TypeScript/JavaScript, plus tsserver request forwarding for vue_ls)
	vim.lsp.config.vtsls = {
		cmd = { "vtsls", "--stdio" },
		filetypes = {
			"typescript",
			"javascript",
			"javascriptreact",
			"typescriptreact",
			"vue",
		},
		root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
		capabilities = capabilities,
		settings = {
			vtsls = {
				tsserver = {
					globalPlugins = {
						vue_plugin,
					},
				},
			},
		},
	}

	-- Vue Language Server
	vim.lsp.config.vue_ls = vim.tbl_deep_extend("force", {
		cmd = { "vue-language-server", "--stdio" },
		filetypes = { "vue" },
		root_markers = { "package.json", ".git" },
		capabilities = capabilities,
	}, vue_ls_config)
end
