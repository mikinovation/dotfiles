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

-- Canned herdr CLI JSON responses (verified against a live herdr 0.7.1 session)
-- and their pre-decoded Lua tables, keyed by the exact JSON string so the
-- vim.json.decode mock can look up a fixture without a real JSON parser.
local RESPONSES = {
	list_empty = '{"id":"1","result":{"agents":[]}}',
	list_one = '{"id":"1","result":{"agents":[{"name":"claude","pane_id":"w1:p1"}]}}',
	list_two = '{"id":"1","result":{"agents":['
		.. '{"name":"claude","pane_id":"w1:p1"},{"name":"reviewer","pane_id":"w1:p2"}]}}',
	list_noname = '{"id":"1","result":{"agents":[{"name":null,"terminal_id":"term_x","pane_id":"w1:p3"}]}}',
	get_ok = '{"id":"1","result":{"agent":{"pane_id":"w1:p1"}}}',
	get_error = '{"id":"1","error":{"code":"agent_not_found","message":"agent target x not found"}}',
	ok = '{"id":"1","result":{"type":"ok"}}',
	start_ok = '{"id":"1","result":{"agent":{"name":"myproj","pane_id":"w1:p5"}}}',
	start_error = '{"id":"1","error":{"code":"agent_name_taken","message":"agent name myproj is already used"}}',
	workspace_list_empty = '{"id":"1","result":{"workspaces":[]}}',
	workspace_list_one = '{"id":"1","result":{"workspaces":[{"label":"dotfiles","workspace_id":"w4"}]}}',
	workspace_list_two = '{"id":"1","result":{"workspaces":['
		.. '{"label":"dotfiles","workspace_id":"w4"},{"label":"scratch","workspace_id":"w7"}]}}',
	workspace_list_nolabel = '{"id":"1","result":{"workspaces":[{"label":null,"workspace_id":"w9"}]}}',
	workspace_focus_error = '{"id":"1","error":{"code":"workspace_not_found","message":"workspace w4 not found"}}',
	malformed = "not json",
}

local JSON_TABLES = {
	[RESPONSES.list_empty] = { result = { agents = {} } },
	[RESPONSES.list_one] = { result = { agents = { { name = "claude", pane_id = "w1:p1" } } } },
	[RESPONSES.list_two] = {
		result = { agents = { { name = "claude", pane_id = "w1:p1" }, { name = "reviewer", pane_id = "w1:p2" } } },
	},
	[RESPONSES.list_noname] = { result = { agents = { { terminal_id = "term_x", pane_id = "w1:p3" } } } },
	[RESPONSES.get_ok] = { result = { agent = { pane_id = "w1:p1" } } },
	[RESPONSES.get_error] = { error = { code = "agent_not_found", message = "agent target x not found" } },
	[RESPONSES.ok] = { result = { type = "ok" } },
	[RESPONSES.start_ok] = { result = { agent = { name = "myproj", pane_id = "w1:p5" } } },
	[RESPONSES.start_error] = { error = { code = "agent_name_taken", message = "agent name myproj is already used" } },
	[RESPONSES.workspace_list_empty] = { result = { workspaces = {} } },
	[RESPONSES.workspace_list_one] = { result = { workspaces = { { label = "dotfiles", workspace_id = "w4" } } } },
	[RESPONSES.workspace_list_two] = {
		result = {
			workspaces = { { label = "dotfiles", workspace_id = "w4" }, { label = "scratch", workspace_id = "w7" } },
		},
	},
	[RESPONSES.workspace_list_nolabel] = { result = { workspaces = { { workspace_id = "w9" } } } },
	[RESPONSES.workspace_focus_error] = { error = { code = "workspace_not_found", message = "workspace w4 not found" } },
}

local notify_calls
local system_calls
local select_calls
local input_calls
local executables
local marks
local env
local responses
local select_choice
local input_text

local function setup_vim_mock()
	notify_calls = {}
	system_calls = {}
	select_calls = {}
	input_calls = {}
	executables = { herdr = true }
	marks = { ["<"] = { 1, 0 }, [">"] = { 1, 5 } }
	env = { HERDR_ENV = "1" }
	select_choice = nil
	input_text = nil

	-- Maps a command key ("agent list", "agent get", "agent send", "agent start",
	-- "pane send-keys") to the canned response string to return; defaults to "ok".
	responses = {
		["agent list"] = RESPONSES.list_one,
		["agent get"] = RESPONSES.get_ok,
		["agent send"] = RESPONSES.ok,
		["agent start"] = RESPONSES.start_ok,
		["pane send-keys"] = RESPONSES.ok,
	}

	_G.vim = {
		fn = {
			executable = function(name)
				return executables[name] and 1 or 0
			end,
			system = function(args)
				table.insert(system_calls, args)
				local key = args[2] .. " " .. args[3]
				local resp = responses[key] or RESPONSES.ok
				_G.vim.v.shell_error = 0
				return resp
			end,
			expand = function(s)
				if s == "%:p:h" then
					return "/home/user/projects/myproj"
				end
				return s
			end,
			fnamemodify = function(path, mods)
				if mods == ":t" then
					return path:match("([^/]+)/?$") or path
				end
				return path
			end,
			getcwd = function()
				return "/fallback/cwd"
			end,
		},
		json = {
			decode = function(s)
				local decoded = JSON_TABLES[s]
				if decoded == nil then
					error("unexpected JSON payload in test: " .. tostring(s))
				end
				return decoded
			end,
		},
		api = {
			nvim_buf_get_mark = function(_, mark)
				return marks[mark]
			end,
			nvim_buf_get_text = function()
				return { "hello" }
			end,
			nvim_get_current_line = function()
				return "current line text"
			end,
			nvim_buf_get_name = function()
				return "/tmp/some/file.lua"
			end,
		},
		ui = {
			select = function(items, opts, cb)
				table.insert(select_calls, { items = items, opts = opts })
				cb(select_choice)
			end,
			input = function(opts, cb)
				table.insert(input_calls, opts)
				cb(input_text)
			end,
		},
		env = env,
		v = { shell_error = 0 },
		log = { levels = { WARN = 2, ERROR = 4, INFO = 1 } },
		notify = function(msg, level)
			table.insert(notify_calls, { msg = msg, level = level })
		end,
		trim = function(s)
			return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
		end,
	}
end

local function load_actions()
	package.loaded["plugins.herdr.actions"] = nil
	return dofile(actions_dir .. "actions.lua")
end

local function has_level(level)
	for _, n in ipairs(notify_calls) do
		if n.level == level then
			return true
		end
	end
	return false
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

describe("plugins.herdr.actions", function()
	local saved_vim

	setup(function()
		saved_vim = _G.vim
	end)

	teardown(function()
		_G.vim = saved_vim
	end)

	before_each(function()
		setup_vim_mock()
	end)

	describe("check_herdr guard", function()
		it("errors when herdr executable is missing", function()
			executables.herdr = false
			load_actions().send_current_line()
			assert.equals(0, #system_calls)
			assert.is_true(has_level(_G.vim.log.levels.ERROR))
		end)

		it("errors when not inside a herdr session", function()
			env.HERDR_ENV = nil
			load_actions().send_current_line()
			assert.equals(0, #system_calls)
			assert.is_true(has_level(_G.vim.log.levels.ERROR))
		end)
	end)

	describe("send_current_line", function()
		it("warns when the current line is empty", function()
			_G.vim.api.nvim_get_current_line = function()
				return "   "
			end
			load_actions().send_current_line()
			assert.equals(0, #system_calls)
			assert.is_true(has_level(_G.vim.log.levels.WARN))
		end)

		it("auto-selects the sole agent and sends line + Enter", function()
			load_actions().send_current_line()
			assert.is_not_nil(find_system_call({ "herdr", "agent", "list" }))
			local send_call = find_system_call({ "herdr", "agent", "send" })
			assert.is_not_nil(send_call)
			assert.equals("claude", send_call[4])
			assert.equals("current line text", send_call[5])
			local keys_call = find_system_call({ "herdr", "pane", "send-keys" })
			assert.is_not_nil(keys_call)
			assert.equals("w1:p1", keys_call[4])
			assert.equals("enter", keys_call[5])
			assert.equals(0, #select_calls)
			assert.is_true(has_level(_G.vim.log.levels.INFO))
		end)

		it("prompts with vim.ui.select when multiple agents are running", function()
			responses["agent list"] = RESPONSES.list_two
			select_choice = "reviewer"
			load_actions().send_current_line()
			assert.equals(1, #select_calls)
			assert.same({ "claude", "reviewer" }, select_calls[1].items)
			local send_call = find_system_call({ "herdr", "agent", "send" })
			assert.equals("reviewer", send_call[4])
		end)

		it("falls back to terminal_id when the agent has no name", function()
			responses["agent list"] = RESPONSES.list_noname
			load_actions().send_current_line()
			local send_call = find_system_call({ "herdr", "agent", "send" })
			assert.equals("term_x", send_call[4])
		end)

		it("warns and sends nothing when no agents are running", function()
			responses["agent list"] = RESPONSES.list_empty
			load_actions().send_current_line()
			assert.is_nil(find_system_call({ "herdr", "agent", "send" }))
			assert.is_true(has_level(_G.vim.log.levels.WARN))
		end)

		it("does not select when the user cancels the picker", function()
			responses["agent list"] = RESPONSES.list_two
			select_choice = nil
			load_actions().send_current_line()
			assert.is_nil(find_system_call({ "herdr", "agent", "send" }))
		end)

		it("errors and sends nothing when the agent cannot be resolved to a pane", function()
			responses["agent get"] = RESPONSES.get_error
			load_actions().send_current_line()
			assert.is_nil(find_system_call({ "herdr", "agent", "send" }))
			assert.is_true(has_level(_G.vim.log.levels.ERROR))
		end)

		it("errors without pressing Enter when agent send fails", function()
			_G.vim.fn.system = function(args)
				table.insert(system_calls, args)
				if args[2] == "agent" and args[3] == "send" then
					_G.vim.v.shell_error = 1
					return ""
				end
				local key = args[2] .. " " .. args[3]
				_G.vim.v.shell_error = 0
				return responses[key] or RESPONSES.ok
			end
			load_actions().send_current_line()
			assert.is_nil(find_system_call({ "herdr", "pane", "send-keys" }))
			assert.is_true(has_level(_G.vim.log.levels.ERROR))
		end)
	end)

	describe("send_selection", function()
		it("warns when there is no visual selection (zero marks)", function()
			marks["<"] = { 0, 0 }
			marks[">"] = { 0, 0 }
			load_actions().send_selection()
			assert.equals(0, #system_calls)
			assert.is_true(has_level(_G.vim.log.levels.WARN))
		end)

		it("sends the selected text to the resolved agent", function()
			load_actions().send_selection()
			local send_call = find_system_call({ "herdr", "agent", "send" })
			assert.equals("hello", send_call[5])
		end)
	end)

	describe("send_prompt", function()
		it("does nothing when the input is cancelled", function()
			input_text = nil
			load_actions().send_prompt()
			assert.equals(1, #input_calls)
			assert.equals(0, #system_calls)
		end)

		it("sends the entered prompt to the resolved agent", function()
			input_text = "do the thing"
			load_actions().send_prompt()
			local send_call = find_system_call({ "herdr", "agent", "send" })
			assert.equals("do the thing", send_call[5])
		end)
	end)

	describe("send_buffer_path", function()
		it("warns when the buffer has no file path", function()
			_G.vim.api.nvim_buf_get_name = function()
				return ""
			end
			load_actions().send_buffer_path()
			assert.equals(0, #system_calls)
			assert.is_true(has_level(_G.vim.log.levels.WARN))
		end)

		it("sends the buffer path to the resolved agent", function()
			load_actions().send_buffer_path()
			local send_call = find_system_call({ "herdr", "agent", "send" })
			assert.equals("/tmp/some/file.lua", send_call[5])
		end)
	end)

	describe("start_claude", function()
		it("does nothing when the input is cancelled", function()
			input_text = nil
			load_actions().start_claude()
			assert.equals(1, #input_calls)
			assert.equals(0, #system_calls)
		end)

		it("prefills the input with the buffer directory's basename", function()
			input_text = nil
			load_actions().start_claude()
			assert.equals("myproj", input_calls[1].default)
		end)

		it("starts a claude agent split right, focused, in the buffer's directory", function()
			input_text = "myproj"
			load_actions().start_claude()
			local start_call = find_system_call({ "herdr", "agent", "start" })
			assert.same({
				"herdr",
				"agent",
				"start",
				"myproj",
				"--cwd",
				"/home/user/projects/myproj",
				"--split",
				"right",
				"--focus",
				"--",
				"claude",
			}, start_call)
			assert.is_true(has_level(_G.vim.log.levels.INFO))
		end)

		it("falls back to Neovim's cwd when the buffer has no directory", function()
			_G.vim.fn.expand = function()
				return ""
			end
			input_text = "myproj"
			load_actions().start_claude()
			local start_call = find_system_call({ "herdr", "agent", "start" })
			assert.equals("/fallback/cwd", start_call[6])
		end)

		it("errors without a success notification when the agent name is taken", function()
			responses["agent start"] = RESPONSES.start_error
			input_text = "myproj"
			load_actions().start_claude()
			assert.is_true(has_level(_G.vim.log.levels.ERROR))
			assert.is_false(has_level(_G.vim.log.levels.INFO))
		end)
	end)

	describe("switch_workspace", function()
		it("warns when no workspaces are found", function()
			responses["workspace list"] = RESPONSES.workspace_list_empty
			load_actions().switch_workspace()
			assert.is_nil(find_system_call({ "herdr", "workspace", "focus" }))
			assert.is_true(has_level(_G.vim.log.levels.WARN))
		end)

		it("auto-focuses the sole workspace", function()
			responses["workspace list"] = RESPONSES.workspace_list_one
			load_actions().switch_workspace()
			local focus_call = find_system_call({ "herdr", "workspace", "focus" })
			assert.is_not_nil(focus_call)
			assert.equals("w4", focus_call[4])
			assert.equals(0, #select_calls)
			assert.is_true(has_level(_G.vim.log.levels.INFO))
		end)

		it("prompts with vim.ui.select when multiple workspaces are running", function()
			responses["workspace list"] = RESPONSES.workspace_list_two
			select_choice = "scratch"
			load_actions().switch_workspace()
			assert.equals(1, #select_calls)
			assert.same({ "dotfiles", "scratch" }, select_calls[1].items)
			local focus_call = find_system_call({ "herdr", "workspace", "focus" })
			assert.equals("w7", focus_call[4])
		end)

		it("falls back to workspace_id when unlabeled", function()
			responses["workspace list"] = RESPONSES.workspace_list_nolabel
			load_actions().switch_workspace()
			local focus_call = find_system_call({ "herdr", "workspace", "focus" })
			assert.equals("w9", focus_call[4])
		end)

		it("does not focus when the user cancels the picker", function()
			responses["workspace list"] = RESPONSES.workspace_list_two
			select_choice = nil
			load_actions().switch_workspace()
			assert.is_nil(find_system_call({ "herdr", "workspace", "focus" }))
		end)

		it("errors without a success notification when focus fails", function()
			responses["workspace list"] = RESPONSES.workspace_list_one
			responses["workspace focus"] = RESPONSES.workspace_focus_error
			load_actions().switch_workspace()
			assert.is_true(has_level(_G.vim.log.levels.ERROR))
			assert.is_false(has_level(_G.vim.log.levels.INFO))
		end)
	end)

	describe("module shape", function()
		it("exports the documented public functions", function()
			local actions = load_actions()
			assert.is_function(actions.send_selection)
			assert.is_function(actions.send_prompt)
			assert.is_function(actions.send_current_line)
			assert.is_function(actions.send_buffer_path)
			assert.is_function(actions.start_claude)
			assert.is_function(actions.switch_workspace)
		end)
	end)
end)
