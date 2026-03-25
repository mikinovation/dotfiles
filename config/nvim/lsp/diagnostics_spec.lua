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
			assert.is_string(float.border, "float.border should be a string")
		end)

		it("has severity_sort enabled", function()
			assert.is_true(helper.captured.diagnostic_config.severity_sort)
		end)
	end)

	describe("diagnostic signs", function()
		local expected_signs = {
			DiagnosticSignError = " ",
			DiagnosticSignWarn = " ",
			DiagnosticSignHint = " ",
			DiagnosticSignInfo = " ",
		}

		for sign_name, expected_icon in pairs(expected_signs) do
			it("defines " .. sign_name, function()
				local sign = helper.captured.signs_defined[sign_name]
				assert.is_not_nil(sign, sign_name .. " should be defined")
				assert.are.equal(expected_icon, sign.text, sign_name .. " should have correct icon")
				assert.are.equal(sign_name, sign.texthl, sign_name .. " should have correct texthl")
			end)
		end
	end)
end)
