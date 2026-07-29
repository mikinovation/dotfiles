-- luacheck: globals describe it before_each setup teardown assert

local helper = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):match("(.*/)") .. "test_helper.lua")
helper.init(helper.get_lsp_dir())

-- Both lsp.keymaps and lsp.features register their own LspAttach autocmd;
-- disambiguate by augroup name rather than returning the first match.
local function get_lspattach_callback()
	for _, autocmd in ipairs(helper.captured.autocmds) do
		if autocmd.event == "LspAttach" and autocmd.opts.group and autocmd.opts.group.name == "UserLspFeatures" then
			return autocmd.opts.callback
		end
	end
	return nil
end

describe("lsp.features", function()
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
			local callback = get_lspattach_callback()
			assert.is_not_nil(callback, "LspAttach autocmd should be registered")
		end)

		it("enables linked_editing_range when the client supports it", function()
			local callback = get_lspattach_callback()
			local mock_client = {
				id = 1,
				supports_method = function(_, method)
					return method == "textDocument/linkedEditingRange"
				end,
			}
			_G.vim.lsp.get_client_by_id = function()
				return mock_client
			end

			callback({ buf = 1, data = { client_id = 1 } })

			assert.is_not_nil(helper.captured.linked_editing_range)
			assert.is_true(helper.captured.linked_editing_range.enable)
			assert.are.equal(1, helper.captured.linked_editing_range.opts.client_id)
		end)

		it("does not enable linked_editing_range when unsupported", function()
			local callback = get_lspattach_callback()
			local mock_client = {
				id = 1,
				supports_method = function()
					return false
				end,
			}
			_G.vim.lsp.get_client_by_id = function()
				return mock_client
			end

			callback({ buf = 1, data = { client_id = 1 } })

			assert.is_nil(helper.captured.linked_editing_range)
		end)

		it("sets LSP foldexpr when the client supports folding range", function()
			local callback = get_lspattach_callback()
			local mock_client = {
				id = 1,
				supports_method = function(_, method)
					return method == "textDocument/foldingRange"
				end,
			}
			_G.vim.lsp.get_client_by_id = function()
				return mock_client
			end

			callback({ buf = 1, data = { client_id = 1 } })

			assert.are.equal("v:lua.vim.lsp.foldexpr()", _G.vim.wo[1000][0].foldexpr)
		end)

		it("does nothing when the client is nil", function()
			local callback = get_lspattach_callback()
			_G.vim.lsp.get_client_by_id = function()
				return nil
			end

			assert.has_no.errors(function()
				callback({ buf = 1, data = { client_id = 1 } })
			end)
		end)
	end)
end)
