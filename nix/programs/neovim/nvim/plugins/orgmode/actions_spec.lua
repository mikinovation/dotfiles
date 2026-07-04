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

local notify_calls
local system_calls
local setreg_calls
local has_heading
local executables
local marks

local function setup_vim_mock()
	notify_calls = {}
	system_calls = {}
	setreg_calls = {}
	has_heading = true
	executables = { pandoc = true }
	marks = { ["<"] = { 1, 0 }, [">"] = { 1, 5 } }

	_G.vim = {
		fn = {
			executable = function(name)
				return executables[name] and 1 or 0
			end,
			system = function(args, stdin)
				table.insert(system_calls, args)
				if type(args) == "table" and args[1] == "pandoc" then
					return "# " .. (stdin or "") .. "\n"
				end
				return ""
			end,
			setreg = function(reg, text)
				table.insert(setreg_calls, { reg = reg, text = text })
			end,
		},
		api = {
			nvim_buf_get_mark = function(_, mark)
				return marks[mark]
			end,
			nvim_buf_get_text = function()
				return { "hello" }
			end,
		},
		v = { shell_error = 0 },
		log = { levels = { WARN = 2, ERROR = 4, INFO = 1 } },
		notify = function(msg, level)
			table.insert(notify_calls, { msg = msg, level = level })
		end,
		trim = function(s)
			return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
		end,
	}

	package.loaded["orgmode.api"] = {
		current = function()
			return {
				get_closest_headline = function()
					if not has_heading then
						return nil
					end
					return {
						id_get_or_create = function() end,
					}
				end,
			}
		end,
	}
end

local function load_actions()
	package.loaded["plugins.orgmode.actions"] = nil
	return dofile(actions_dir .. "actions.lua")
end

describe("plugins.orgmode.actions", function()
	local saved_vim, saved_orgmode_api

	setup(function()
		saved_vim = _G.vim
		saved_orgmode_api = package.loaded["orgmode.api"]
	end)

	teardown(function()
		_G.vim = saved_vim
		package.loaded["orgmode.api"] = saved_orgmode_api
	end)

	before_each(function()
		setup_vim_mock()
	end)

	describe("copy_as_markdown", function()
		it("errors when pandoc is not installed", function()
			executables.pandoc = false
			load_actions().copy_as_markdown()
			local has_error = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.ERROR then
					has_error = true
				end
			end
			assert.is_true(has_error)
		end)

		it("warns when there is no visual selection (zero marks)", function()
			marks["<"] = { 0, 0 }
			marks[">"] = { 0, 0 }
			load_actions().copy_as_markdown()
			local has_warn = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.WARN then
					has_warn = true
				end
			end
			assert.is_true(has_warn)
		end)

		it("warns when the selected text is empty", function()
			_G.vim.api.nvim_buf_get_text = function()
				return { "" }
			end
			load_actions().copy_as_markdown()
			local has_warn = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.WARN then
					has_warn = true
				end
			end
			assert.is_true(has_warn)
		end)

		it("copies pandoc output to the + register and notifies", function()
			load_actions().copy_as_markdown()
			assert.equals(1, #setreg_calls)
			assert.equals("+", setreg_calls[1].reg)
			local has_info = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.INFO then
					has_info = true
				end
			end
			assert.is_true(has_info)
		end)

		it("errors when pandoc conversion fails", function()
			_G.vim.fn.system = function(args, _)
				table.insert(system_calls, args)
				if type(args) == "table" and args[1] == "pandoc" then
					_G.vim.v.shell_error = 1
				end
				return ""
			end
			load_actions().copy_as_markdown()
			local has_error = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.ERROR then
					has_error = true
				end
			end
			assert.is_true(has_error)
		end)
	end)

	describe("id_get_or_create", function()
		it("warns when there is no heading at cursor", function()
			has_heading = false
			load_actions().id_get_or_create()
			local has_warn = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.WARN then
					has_warn = true
				end
			end
			assert.is_true(has_warn)
		end)

		it("calls id_get_or_create on the closest heading", function()
			has_heading = true
			-- Just assert no crash/notify happens on the happy path.
			load_actions().id_get_or_create()
			assert.equals(0, #notify_calls)
		end)
	end)

	describe("module shape", function()
		it("exports the documented public functions", function()
			local actions = load_actions()
			assert.is_function(actions.copy_as_markdown)
			assert.is_function(actions.id_get_or_create)
		end)
	end)
end)
