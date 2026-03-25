-- luacheck: globals describe it before_each setup teardown assert

local helper = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):match("(.*/)") .. "test_helper.lua")
helper.init(helper.get_lsp_dir())

describe("lsp servers", function()
	setup(function()
		helper.save_state()
	end)

	teardown(function()
		helper.restore_state()
	end)

	before_each(function()
		helper.setup_vim_mock()
		helper.load_lsp()
	end)

	describe("LSP server configurations", function()
		-- Servers that must be defined in vim.lsp.config
		local expected_servers = {
			"lua_ls",
			"rust_analyzer",
			"vtsls",
			"vue_ls",
			"ts_ls",
			"tailwindcss",
			"solargraph",
		}

		it("has no unexpected servers", function()
			local expected_set = {}
			for _, name in ipairs(expected_servers) do
				expected_set[name] = true
			end

			local unexpected = {}
			for name, _ in pairs(helper.captured.lsp_config_store) do
				if not expected_set[name] then
					table.insert(unexpected, name)
				end
			end
			assert.same(
				{},
				unexpected,
				"unexpected servers found: " .. table.concat(unexpected, ", ") .. " — add them to expected_servers"
			)
		end)

		for _, server_name in ipairs(expected_servers) do
			describe(server_name, function()
				it("is configured", function()
					local config = helper.captured.lsp_config_store[server_name]
					assert.is_not_nil(config, server_name .. " should be configured in vim.lsp.config")
					assert.is_table(config, server_name .. " config should be a table")
				end)

				it("has cmd field", function()
					local config = helper.captured.lsp_config_store[server_name]
					assert.is_table(config.cmd, server_name .. " must have cmd as a table")
					assert.truthy(#config.cmd > 0, server_name .. " cmd must not be empty")
					assert.is_string(config.cmd[1], server_name .. " cmd[1] must be a string (executable name)")
				end)

				it("has filetypes field", function()
					local config = helper.captured.lsp_config_store[server_name]
					assert.is_table(config.filetypes, server_name .. " must have filetypes as a table")
					assert.truthy(#config.filetypes > 0, server_name .. " filetypes must not be empty")
				end)
			end)
		end
	end)

	describe("vim.lsp.enable", function()
		it("enables all expected servers", function()
			local enabled = helper.captured.lsp_servers_enabled
			assert.is_table(enabled, "vim.lsp.enable should be called with a table")
			assert.truthy(#enabled > 0, "at least one server should be enabled")
		end)

		it("every enabled server has a corresponding config", function()
			for _, server_name in ipairs(helper.captured.lsp_servers_enabled) do
				local config = helper.captured.lsp_config_store[server_name]
				assert.is_not_nil(
					config,
					"enabled server '" .. server_name .. "' has no corresponding vim.lsp.config entry"
				)
			end
		end)
	end)
end)
