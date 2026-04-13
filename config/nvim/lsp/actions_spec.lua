-- luacheck: globals describe it before_each setup teardown assert

local function spec_dir()
	local info = debug.getinfo(1, "S")
	local file = info.source:gsub("^@", "")
	if not file:match("^/") then
		local handle = io.popen("pwd")
		if handle then
			file = handle:read("*l") .. "/" .. file
			handle:close()
		end
	end
	return file:match("(.*/)")
end

local lsp_dir = spec_dir()

describe("lsp.actions", function()
	local saved_vim
	local format_calls

	setup(function()
		saved_vim = _G.vim
	end)

	teardown(function()
		_G.vim = saved_vim
	end)

	before_each(function()
		format_calls = {}
		_G.vim = {
			lsp = {
				buf = {
					format = function(opts)
						table.insert(format_calls, opts)
					end,
				},
			},
		}
	end)

	describe("format_document", function()
		it("calls vim.lsp.buf.format with async = true", function()
			local actions = dofile(lsp_dir .. "actions.lua")
			actions.format_document()
			assert.equals(1, #format_calls)
			assert.same({ async = true }, format_calls[1])
		end)
	end)

	describe("module shape", function()
		it("exports format_document", function()
			local actions = dofile(lsp_dir .. "actions.lua")
			assert.is_function(actions.format_document)
		end)
	end)
end)
