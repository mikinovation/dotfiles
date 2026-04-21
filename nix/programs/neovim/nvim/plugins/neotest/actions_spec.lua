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

local actions_dir = spec_dir()

describe("plugins.neotest.actions", function()
	local saved_vim, saved_neotest
	local run_calls

	setup(function()
		saved_vim = _G.vim
		saved_neotest = package.loaded["neotest"]
	end)

	teardown(function()
		_G.vim = saved_vim
		package.loaded["neotest"] = saved_neotest
	end)

	before_each(function()
		run_calls = {}
		_G.vim = {
			fn = {
				expand = function(s)
					if s == "%" then
						return "/abs/path/test_spec.lua"
					end
					return s
				end,
			},
		}
		package.loaded["neotest"] = {
			run = {
				run = function(...)
					table.insert(run_calls, { n = select("#", ...), arg = (select(1, ...)) })
				end,
			},
		}
	end)

	describe("run_nearest", function()
		it("invokes neotest.run.run with no argument", function()
			local actions = dofile(actions_dir .. "actions.lua")
			actions.run_nearest()
			assert.equals(1, #run_calls)
			assert.equals(0, run_calls[1].n, "should be called with zero arguments")
		end)
	end)

	describe("debug_nearest", function()
		it("invokes neotest.run.run with the dap strategy", function()
			local actions = dofile(actions_dir .. "actions.lua")
			actions.debug_nearest()
			assert.equals(1, #run_calls)
			assert.equals(1, run_calls[1].n)
			assert.same({ strategy = "dap" }, run_calls[1].arg)
		end)
	end)

	describe("run_file", function()
		it("invokes neotest.run.run with the current buffer's file path", function()
			local actions = dofile(actions_dir .. "actions.lua")
			actions.run_file()
			assert.equals(1, #run_calls)
			assert.equals(1, run_calls[1].n)
			assert.equals("/abs/path/test_spec.lua", run_calls[1].arg)
		end)
	end)

	describe("module shape", function()
		it("exports the documented public functions", function()
			local actions = dofile(actions_dir .. "actions.lua")
			assert.is_function(actions.run_nearest)
			assert.is_function(actions.debug_nearest)
			assert.is_function(actions.run_file)
		end)
	end)
end)
