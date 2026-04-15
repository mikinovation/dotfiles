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
local heading_props
local has_heading
local executables
local marks

local function setup_vim_mock()
	notify_calls = {}
	system_calls = {}
	setreg_calls = {}
	heading_props = {}
	has_heading = true
	executables = { tmux = true, claude = true, pandoc = true }
	marks = { ["<"] = { 1, 0 }, [">"] = { 1, 5 } }

	_G.vim = {
		fn = {
			expand = function(s)
				return s
			end,
			isdirectory = function()
				return 1
			end,
			executable = function(name)
				return executables[name] and 1 or 0
			end,
			system = function(args, stdin)
				table.insert(system_calls, args)
				if type(args) == "string" and args:match("list%-panes") then
					return "1"
				end
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
		env = { TMUX = "/tmp/tmux-1000/default,1234,0" },
		v = { shell_error = 0 },
		log = { levels = { WARN = 2, ERROR = 4, INFO = 1 } },
		notify = function(msg, level)
			table.insert(notify_calls, { msg = msg, level = level })
		end,
		trim = function(s)
			return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
		end,
	}

	package.loaded["orgmode"] = {
		files = {
			get_closest_headline = function()
				if not has_heading then
					return nil
				end
				return {
					get_property = function(_, name)
						return heading_props[name]
					end,
				}
			end,
		},
	}
end

local function load_actions()
	package.loaded["plugins.orgmode.actions"] = nil
	return dofile(actions_dir .. "actions.lua")
end

local function find_system_call(prefix)
	for _, call in ipairs(system_calls) do
		if type(call) == "table" and call[1] == prefix[1] then
			local match = true
			for i, v in ipairs(prefix) do
				if call[i] ~= v then
					match = false
					break
				end
			end
			if match then
				return call
			end
		end
	end
	return nil
end

describe("plugins.orgmode.actions", function()
	local saved_vim, saved_orgmode

	setup(function()
		saved_vim = _G.vim
		saved_orgmode = package.loaded["orgmode"]
	end)

	teardown(function()
		_G.vim = saved_vim
		package.loaded["orgmode"] = saved_orgmode
	end)

	before_each(function()
		setup_vim_mock()
	end)

	describe("open_nvim_pane", function()
		it("warns and returns when no heading is found", function()
			has_heading = false
			load_actions().open_nvim_pane()
			assert.equals(0, #system_calls)
			assert.is_true(#notify_calls > 0)
			assert.equals(_G.vim.log.levels.WARN, notify_calls[1].level)
		end)

		it("warns when the heading lacks a :DIR: property", function()
			heading_props.DIR = nil
			load_actions().open_nvim_pane()
			assert.equals(0, #system_calls)
			assert.is_true(#notify_calls > 0)
			assert.equals(_G.vim.log.levels.WARN, notify_calls[1].level)
		end)

		it("errors when the resolved directory does not exist", function()
			heading_props.DIR = "~/missing"
			_G.vim.fn.isdirectory = function()
				return 0
			end
			load_actions().open_nvim_pane()
			assert.equals(0, #system_calls)
			local has_error = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.ERROR then
					has_error = true
				end
			end
			assert.is_true(has_error)
		end)

		it("errors when tmux executable is missing", function()
			heading_props.DIR = "~/dir"
			executables.tmux = false
			load_actions().open_nvim_pane()
			-- close_other_panes shouldn't fire either
			assert.is_nil(find_system_call({ "tmux", "split-window" }))
			local has_error = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.ERROR then
					has_error = true
				end
			end
			assert.is_true(has_error)
		end)

		it("errors when not inside a tmux session", function()
			heading_props.DIR = "~/dir"
			_G.vim.env.TMUX = nil
			load_actions().open_nvim_pane()
			assert.is_nil(find_system_call({ "tmux", "split-window" }))
		end)

		it("opens a tmux split with nvim and notifies on success", function()
			heading_props.DIR = "~/dir"
			load_actions().open_nvim_pane()
			local call = find_system_call({ "tmux", "split-window" })
			assert.is_not_nil(call)
			assert.equals("nvim", call[#call])
			-- INFO notification on success
			local has_info = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.INFO then
					has_info = true
				end
			end
			assert.is_true(has_info)
		end)

		it("notifies on shell error from tmux split", function()
			heading_props.DIR = "~/dir"
			_G.vim.fn.system = function(args)
				table.insert(system_calls, args)
				if type(args) == "table" and args[2] == "split-window" then
					_G.vim.v.shell_error = 1
				end
				return ""
			end
			load_actions().open_nvim_pane()
			local has_error = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.ERROR then
					has_error = true
				end
			end
			assert.is_true(has_error)
		end)
	end)

	describe("resume_claude_session", function()
		it("warns when :SESSION_ID: is missing", function()
			heading_props.DIR = "~/dir"
			heading_props.SESSION_ID = nil
			load_actions().resume_claude_session()
			assert.is_nil(find_system_call({ "tmux", "split-window" }))
			local has_warn = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.WARN then
					has_warn = true
				end
			end
			assert.is_true(has_warn)
		end)

		it("errors when claude executable is missing", function()
			heading_props.DIR = "~/dir"
			heading_props.SESSION_ID = "abc-123"
			executables.claude = false
			load_actions().resume_claude_session()
			assert.is_nil(find_system_call({ "tmux", "split-window" }))
		end)

		it("opens claude --resume in the right pane on success", function()
			heading_props.DIR = "~/dir"
			heading_props.SESSION_ID = "abc-123"
			load_actions().resume_claude_session()
			local call = find_system_call({ "tmux", "split-window" })
			assert.is_not_nil(call)
			-- last three args should be the claude command + flag + session id
			assert.equals("abc-123", call[#call])
			assert.equals("--resume", call[#call - 1])
			assert.equals("claude", call[#call - 2])
		end)
	end)

	describe("send_prompt_to_claude", function()
		it("requires tmux to be available", function()
			executables.tmux = false
			load_actions().send_prompt_to_claude()
			assert.is_nil(find_system_call({ "tmux", "send-keys" }))
		end)

		it("warns when there is no visual selection (zero marks)", function()
			marks["<"] = { 0, 0 }
			marks[">"] = { 0, 0 }
			load_actions().send_prompt_to_claude()
			assert.is_nil(find_system_call({ "tmux", "send-keys" }))
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
			load_actions().send_prompt_to_claude()
			assert.is_nil(find_system_call({ "tmux", "send-keys" }))
		end)

		it("sends the selection text to the right tmux pane", function()
			load_actions().send_prompt_to_claude()
			local call = find_system_call({ "tmux", "send-keys" })
			assert.is_not_nil(call)
			-- tmux send-keys -t {right} <payload> Enter
			assert.equals("-t", call[3])
			assert.equals("{right}", call[4])
			assert.equals("hello", call[5])
			assert.equals("Enter", call[6])
		end)

		it("normalizes inverted marks (end before start) before extraction", function()
			marks["<"] = { 5, 10 }
			marks[">"] = { 1, 0 }
			-- Just assert no crash and that a send-keys call happens.
			load_actions().send_prompt_to_claude()
			assert.is_not_nil(find_system_call({ "tmux", "send-keys" }))
		end)

		it("notifies on shell error from tmux send-keys", function()
			_G.vim.fn.system = function(args)
				table.insert(system_calls, args)
				if type(args) == "table" and args[2] == "send-keys" then
					_G.vim.v.shell_error = 1
				end
				return ""
			end
			load_actions().send_prompt_to_claude()
			local has_error = false
			for _, n in ipairs(notify_calls) do
				if n.level == _G.vim.log.levels.ERROR then
					has_error = true
				end
			end
			assert.is_true(has_error)
		end)
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

	describe("open_terminal_pane", function()
		it("warns when :DIR: is missing", function()
			heading_props.DIR = nil
			load_actions().open_terminal_pane()
			assert.is_nil(find_system_call({ "tmux", "split-window" }))
		end)

		it("opens a tmux split without a trailing command (terminal)", function()
			heading_props.DIR = "~/dir"
			load_actions().open_terminal_pane()
			local call = find_system_call({ "tmux", "split-window" })
			assert.is_not_nil(call)
			-- Last arg should be the directory ("~/dir"), not "nvim"
			assert.equals("~/dir", call[#call])
		end)
	end)

	describe("module shape", function()
		it("exports the documented public functions", function()
			local actions = load_actions()
			assert.is_function(actions.open_nvim_pane)
			assert.is_function(actions.resume_claude_session)
			assert.is_function(actions.send_prompt_to_claude)
			assert.is_function(actions.copy_as_markdown)
			assert.is_function(actions.open_terminal_pane)
		end)
	end)
end)
