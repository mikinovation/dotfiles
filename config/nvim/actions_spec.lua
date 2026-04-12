-- luacheck: globals describe it before_each setup teardown assert

-- Resolve the directory containing this spec file.
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

local nvim_dir = spec_dir()

local lazydocker_calls
local system_calls

local function setup_vim_mock()
	system_calls = {}
	_G.vim = {
		fn = {
			expand = function(s)
				if s == "%:p:h" then
					return "/home/u/project/src"
				end
				return s
			end,
			system = function(args)
				table.insert(system_calls, args)
				if type(args) == "table" and args[1] == "wslpath" then
					return "C:\\home\\u\\project\\src\n"
				end
				return ""
			end,
		},
		lsp = {
			buf = {
				format_calls = {},
				format = function(opts)
					table.insert(_G.vim.lsp.buf.format_calls, opts)
				end,
			},
		},
	}
end

describe("actions (global)", function()
	local saved_vim, saved_path, saved_lazydocker

	setup(function()
		saved_vim = _G.vim
		saved_path = package.path
		saved_lazydocker = package.loaded["tools.lazydocker"]
		package.path = nvim_dir .. "?.lua;" .. nvim_dir .. "?/init.lua;" .. package.path
	end)

	teardown(function()
		_G.vim = saved_vim
		package.path = saved_path
		package.loaded["tools.lazydocker"] = saved_lazydocker
		package.loaded["actions"] = nil
	end)

	before_each(function()
		setup_vim_mock()
		lazydocker_calls = 0
		package.loaded["tools.lazydocker"] = {
			toggle_lazydocker = function()
				lazydocker_calls = lazydocker_calls + 1
			end,
		}
		package.loaded["actions"] = nil
	end)

	describe("format_document", function()
		it("calls vim.lsp.buf.format with async = true", function()
			local actions = dofile(nvim_dir .. "actions.lua")
			actions.format_document()
			assert.equals(1, #_G.vim.lsp.buf.format_calls)
			assert.same({ async = true }, _G.vim.lsp.buf.format_calls[1])
		end)
	end)

	describe("open_in_explorer", function()
		it("translates the buffer's directory via wslpath then opens explorer.exe", function()
			local actions = dofile(nvim_dir .. "actions.lua")
			actions.open_in_explorer()

			assert.equals(2, #system_calls, "should invoke wslpath and explorer.exe")
			assert.same({ "wslpath", "-w", "/home/u/project/src" }, system_calls[1])
			assert.same({ "explorer.exe", "C:\\home\\u\\project\\src" }, system_calls[2])
		end)

		it("strips the trailing newline from the wslpath output", function()
			local actions = dofile(nvim_dir .. "actions.lua")
			actions.open_in_explorer()
			-- The second call's path argument should not contain a newline
			assert.is_nil(system_calls[2][2]:find("\n"))
		end)
	end)

	describe("toggle_lazydocker", function()
		it("delegates to tools.lazydocker.toggle_lazydocker", function()
			local actions = dofile(nvim_dir .. "actions.lua")
			actions.toggle_lazydocker()
			assert.equals(1, lazydocker_calls)
		end)

		it("can be invoked multiple times", function()
			local actions = dofile(nvim_dir .. "actions.lua")
			actions.toggle_lazydocker()
			actions.toggle_lazydocker()
			assert.equals(2, lazydocker_calls)
		end)
	end)

	describe("module shape", function()
		it("exports the documented public functions", function()
			local actions = dofile(nvim_dir .. "actions.lua")
			assert.is_function(actions.format_document)
			assert.is_function(actions.open_in_explorer)
			assert.is_function(actions.toggle_lazydocker)
		end)
	end)
end)
