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

local tools_dir = spec_dir()
local nvim_dir = tools_dir:gsub("tools/$", "")

local systemlist_calls
local jobstart_calls
local jobstop_calls
local jobwait_returns
local notify_calls
local executable_map
local next_job_id

local function setup_vim_mock()
	systemlist_calls = {}
	jobstart_calls = {}
	jobstop_calls = {}
	jobwait_returns = {}
	notify_calls = {}
	executable_map = { difit = 1 }
	next_job_id = 1
	_G.vim = {
		fn = {
			executable = function(cmd)
				return executable_map[cmd] or 0
			end,
			systemlist = function(args)
				table.insert(systemlist_calls, args)
				return _G.vim._systemlist_result or {}
			end,
			jobstart = function(args, opts)
				table.insert(jobstart_calls, { args = args, opts = opts })
				local id = next_job_id
				next_job_id = next_job_id + 1
				return id
			end,
			jobstop = function(id)
				table.insert(jobstop_calls, id)
				return 1
			end,
			jobwait = function(ids, _)
				local result = {}
				for _, id in ipairs(ids) do
					result[#result + 1] = jobwait_returns[id] or -1
				end
				return result
			end,
		},
		v = { shell_error = 0 },
		log = { levels = { WARN = 2, ERROR = 4, INFO = 1 } },
		notify = function(msg, level)
			table.insert(notify_calls, { msg = msg, level = level })
		end,
		schedule = function(fn)
			fn()
		end,
	}
end

local function load_difit()
	package.loaded["tools.difit"] = nil
	return dofile(tools_dir .. "difit.lua")
end

describe("tools.difit", function()
	local saved_vim, saved_path, saved_loaded

	setup(function()
		saved_vim = _G.vim
		saved_path = package.path
		saved_loaded = package.loaded["tools.difit"]
		package.path = nvim_dir .. "?.lua;" .. nvim_dir .. "?/init.lua;" .. package.path
	end)

	teardown(function()
		_G.vim = saved_vim
		package.path = saved_path
		package.loaded["tools.difit"] = saved_loaded
	end)

	before_each(function()
		setup_vim_mock()
	end)

	describe("is_available", function()
		it("returns true when difit is on PATH", function()
			executable_map = { difit = 1 }
			local difit = load_difit()
			assert.is_true(difit.is_available())
		end)

		it("returns false when difit is not on PATH", function()
			executable_map = { difit = 0 }
			local difit = load_difit()
			assert.is_false(difit.is_available())
		end)
	end)

	describe("list_branches", function()
		it("returns local and remote branches, skipping HEAD aliases", function()
			_G.vim._systemlist_result = {
				"main",
				"feature/x",
				"origin/HEAD",
				"origin/main",
				"origin/feature/x",
			}
			local difit = load_difit()
			local branches = difit.list_branches()
			assert.same({ "main", "feature/x", "origin/main", "origin/feature/x" }, branches)
			assert.equals(1, #systemlist_calls)
			local args = systemlist_calls[1]
			assert.equals("git", args[1])
			assert.equals("for-each-ref", args[2])
		end)

		it("returns an empty list when git fails", function()
			_G.vim._systemlist_result = {}
			_G.vim.v.shell_error = 128
			local difit = load_difit()
			assert.same({}, difit.list_branches())
		end)

		it("filters out empty entries", function()
			_G.vim._systemlist_result = { "main", "", "dev" }
			local difit = load_difit()
			assert.same({ "main", "dev" }, difit.list_branches())
		end)
	end)

	describe("start", function()
		it("notifies and aborts when difit is not installed", function()
			executable_map = { difit = 0 }
			local difit = load_difit()
			difit.start("main")
			assert.equals(0, #jobstart_calls)
			assert.equals(1, #notify_calls)
			assert.equals(_G.vim.log.levels.ERROR, notify_calls[1].level)
		end)

		it("launches difit with @ <base> and tracks the job id", function()
			local difit = load_difit()
			difit.start("main")
			assert.equals(1, #jobstart_calls)
			assert.same({ "difit", "@", "main" }, jobstart_calls[1].args)
			assert.is_true(difit.is_running())
		end)

		it("refuses to start when another job is already running", function()
			local difit = load_difit()
			difit.start("main")
			jobwait_returns[1] = -1
			difit.start("dev")
			assert.equals(1, #jobstart_calls)
			local warned = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.WARN then
					warned = true
				end
			end
			assert.is_true(warned)
		end)

		it("clears the tracked job id on exit", function()
			local difit = load_difit()
			difit.start("main")
			local opts = jobstart_calls[1].opts
			assert.is_function(opts.on_exit)
			opts.on_exit(1, 0)
			assert.is_false(difit.is_running())
		end)

		it("notifies when jobstart fails", function()
			_G.vim.fn.jobstart = function()
				return -1
			end
			local difit = load_difit()
			difit.start("main")
			assert.is_false(difit.is_running())
			local saw_error = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.ERROR then
					saw_error = true
				end
			end
			assert.is_true(saw_error)
		end)
	end)

	describe("stop", function()
		it("calls jobstop on the tracked job", function()
			local difit = load_difit()
			difit.start("main")
			jobwait_returns[1] = -1
			difit.stop()
			assert.same({ 1 }, jobstop_calls)
			assert.is_false(difit.is_running())
		end)

		it("is a no-op when nothing is running", function()
			local difit = load_difit()
			difit.stop()
			assert.equals(0, #jobstop_calls)
		end)
	end)

	describe("module shape", function()
		it("exports the documented public functions", function()
			local difit = load_difit()
			assert.is_function(difit.is_available)
			assert.is_function(difit.list_branches)
			assert.is_function(difit.start)
			assert.is_function(difit.stop)
			assert.is_function(difit.is_running)
			assert.is_function(difit.pick_base_and_start)
		end)
	end)
end)
