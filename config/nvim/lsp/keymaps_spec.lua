-- luacheck: globals describe it before_each setup teardown assert

local helper = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):match("(.*/)") .. "test_helper.lua")
helper.init(helper.get_lsp_dir())

describe("lsp keymaps", function()
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

	describe("LspAttach autocmd", function()
		it("creates an LspAttach autocmd", function()
			local found = false
			for _, autocmd in ipairs(helper.captured.autocmds) do
				if autocmd.event == "LspAttach" then
					found = true
					break
				end
			end
			assert.is_true(found, "LspAttach autocmd should be registered")
		end)

		it("has a callback function", function()
			for _, autocmd in ipairs(helper.captured.autocmds) do
				if autocmd.event == "LspAttach" then
					assert.is_function(autocmd.opts.callback, "LspAttach autocmd should have a callback function")
					return
				end
			end
		end)

		it("callback registers keymaps without error", function()
			for _, autocmd in ipairs(helper.captured.autocmds) do
				if autocmd.event == "LspAttach" then
					-- Simulate LspAttach event with a mock client that supports formatting
					local mock_client = {
						supports_method = function(method)
							return method == "textDocument/formatting"
						end,
					}
					_G.vim.lsp.get_client_by_id = function()
						return mock_client
					end

					local keymap_calls = {}
					_G.vim.keymap.set = function(mode, lhs, rhs, opts)
						table.insert(keymap_calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
					end

					assert.has_no.errors(function()
						autocmd.opts.callback({ buf = 1, data = { client_id = 1 } })
					end)

					-- Verify keymaps were registered
					assert.truthy(#keymap_calls > 0, "keymaps should be registered on LspAttach")

					-- Check for expected keymaps
					local registered_keys = {}
					for _, call in ipairs(keymap_calls) do
						registered_keys[call.lhs] = true
					end

					local essential_keys = { "gd", "gr", "gI", "gD", "K", "<leader>rn", "<leader>ca" }
					for _, key in ipairs(essential_keys) do
						assert.is_true(registered_keys[key], "essential keymap '" .. key .. "' should be registered")
					end

					return
				end
			end
		end)

		it("callback registers format keymap when client supports formatting", function()
			for _, autocmd in ipairs(helper.captured.autocmds) do
				if autocmd.event == "LspAttach" then
					local mock_client = {
						supports_method = function(method)
							return method == "textDocument/formatting"
						end,
					}
					_G.vim.lsp.get_client_by_id = function()
						return mock_client
					end

					local keymap_calls = {}
					_G.vim.keymap.set = function(mode, lhs, rhs, opts)
						table.insert(keymap_calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
					end

					autocmd.opts.callback({ buf = 1, data = { client_id = 1 } })

					local has_format = false
					for _, call in ipairs(keymap_calls) do
						if call.lhs == "<leader>f" then
							has_format = true
							break
						end
					end
					assert.is_true(has_format, "<leader>f should be registered when formatting is supported")
					return
				end
			end
		end)

		it("callback does not register format keymap when client lacks formatting", function()
			for _, autocmd in ipairs(helper.captured.autocmds) do
				if autocmd.event == "LspAttach" then
					local mock_client = {
						supports_method = function()
							return false
						end,
					}
					_G.vim.lsp.get_client_by_id = function()
						return mock_client
					end

					local keymap_calls = {}
					_G.vim.keymap.set = function(mode, lhs, rhs, opts)
						table.insert(keymap_calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
					end

					autocmd.opts.callback({ buf = 1, data = { client_id = 1 } })

					local has_format = false
					for _, call in ipairs(keymap_calls) do
						if call.lhs == "<leader>f" then
							has_format = true
							break
						end
					end
					assert.is_false(has_format, "<leader>f should NOT be registered when formatting is unsupported")
					return
				end
			end
		end)

		it("all keymaps are normal mode and buffer-local", function()
			for _, autocmd in ipairs(helper.captured.autocmds) do
				if autocmd.event == "LspAttach" then
					local mock_client = {
						supports_method = function()
							return true
						end,
					}
					_G.vim.lsp.get_client_by_id = function()
						return mock_client
					end

					local keymap_calls = {}
					_G.vim.keymap.set = function(mode, lhs, rhs, opts)
						table.insert(keymap_calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
					end

					autocmd.opts.callback({ buf = 1, data = { client_id = 1 } })

					for _, call in ipairs(keymap_calls) do
						assert.are.equal("n", call.mode, "keymap '" .. call.lhs .. "' should be normal mode")
						assert.is_number(call.opts.buffer, "keymap '" .. call.lhs .. "' should be buffer-local")
					end
					return
				end
			end
		end)

		it("no duplicate keymaps are registered", function()
			for _, autocmd in ipairs(helper.captured.autocmds) do
				if autocmd.event == "LspAttach" then
					local mock_client = {
						supports_method = function()
							return true
						end,
					}
					_G.vim.lsp.get_client_by_id = function()
						return mock_client
					end

					local keymap_calls = {}
					_G.vim.keymap.set = function(mode, lhs, rhs, opts)
						table.insert(keymap_calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
					end

					autocmd.opts.callback({ buf = 1, data = { client_id = 1 } })

					local seen = {}
					local duplicates = {}
					for _, call in ipairs(keymap_calls) do
						if seen[call.lhs] then
							table.insert(duplicates, call.lhs)
						end
						seen[call.lhs] = true
					end
					assert.same({}, duplicates, "duplicate keymaps found: " .. table.concat(duplicates, ", "))
					return
				end
			end
		end)
	end)
end)
