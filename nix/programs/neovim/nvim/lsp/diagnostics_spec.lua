-- luacheck: globals describe it before_each setup teardown assert

local helper = dofile(debug.getinfo(1, "S").source:gsub("^@", ""):match("(.*/)") .. "test_helper.lua")
helper.init(helper.get_lsp_dir())

describe("lsp diagnostics", function()
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

	describe("diagnostic config", function()
		it("is configured", function()
			assert.is_not_nil(helper.captured.diagnostic_config, "vim.diagnostic.config should be called")
			assert.is_table(helper.captured.diagnostic_config)
		end)

		it("has virtual_text settings", function()
			local vt = helper.captured.diagnostic_config.virtual_text
			assert.is_table(vt, "virtual_text should be configured")
			assert.is_string(vt.prefix, "virtual_text.prefix should be a string")
		end)

		it("has float settings", function()
			local float = helper.captured.diagnostic_config.float
			assert.is_table(float, "float should be configured")
			assert.is_false(float.focusable, "float.focusable should be false")
			assert.are.equal("if_many", float.source, "float.source should be 'if_many'")
		end)

		it("has severity_sort enabled", function()
			assert.is_true(helper.captured.diagnostic_config.severity_sort)
		end)
	end)

	describe("diagnostic signs", function()
		it("defines sign text per severity", function()
			local signs = helper.captured.diagnostic_config.signs
			assert.is_table(signs, "signs should be configured as a table")
			assert.is_table(signs.text, "signs.text should be a table")
			assert.are.equal(" ", signs.text[vim.diagnostic.severity.ERROR])
			assert.are.equal(" ", signs.text[vim.diagnostic.severity.WARN])
			assert.are.equal(" ", signs.text[vim.diagnostic.severity.HINT])
			assert.are.equal(" ", signs.text[vim.diagnostic.severity.INFO])
		end)

		it("defines sign numhl per severity", function()
			local signs = helper.captured.diagnostic_config.signs
			assert.is_table(signs.numhl, "signs.numhl should be a table")
			assert.are.equal("DiagnosticSignError", signs.numhl[vim.diagnostic.severity.ERROR])
			assert.are.equal("DiagnosticSignWarn", signs.numhl[vim.diagnostic.severity.WARN])
			assert.are.equal("DiagnosticSignHint", signs.numhl[vim.diagnostic.severity.HINT])
			assert.are.equal("DiagnosticSignInfo", signs.numhl[vim.diagnostic.severity.INFO])
		end)
	end)

	describe("diagnostic virtual_lines", function()
		it("shows virtual lines for the current line only", function()
			local vl = helper.captured.diagnostic_config.virtual_lines
			assert.is_table(vl, "virtual_lines should be configured")
			assert.is_true(vl.current_line)
		end)
	end)
end)
