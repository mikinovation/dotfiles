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

local builtin_calls
local theme_calls
local notify_calls
local cmd_calls
local input_queue
local extension_calls
local fail_git_files

local function record(target, name)
	return function(...)
		table.insert(target, { name = name, args = { ... } })
	end
end

local function setup_vim_mock()
	builtin_calls = {}
	theme_calls = {}
	notify_calls = {}
	cmd_calls = {}
	input_queue = {}
	extension_calls = {}
	fail_git_files = false

	local function noop_input()
		if #input_queue == 0 then
			return ""
		end
		return table.remove(input_queue, 1)
	end

	_G.vim = {
		fn = {
			expand = function(arg)
				if arg == "<cword>" then
					return "needle"
				end
				if arg == "%:p" then
					return _G.vim._current_file or ""
				end
				return arg
			end,
			fnamemodify = function(path, modifier)
				if modifier == ":h" then
					return path:match("(.*)/[^/]+$") or path
				elseif modifier == ":~" then
					return path:gsub("^/home/[^/]+", "~")
				end
				return path
			end,
			getpos = function(mark)
				if mark == "'<" then
					return { 0, 1, 1, 0 }
				end
				return { 0, 1, 5, 0 }
			end,
			getreg = function()
				return _G.vim._yank or ""
			end,
			input = function(prompt, default)
				return noop_input(prompt, default)
			end,
			escape = function(s, _)
				return s
			end,
			stdpath = function(what)
				if what == "config" then
					return "/etc/nvim"
				end
				return "/tmp"
			end,
		},
		api = {
			nvim_buf_get_lines = function()
				return { "hello world" }
			end,
		},
		keymap = { set = function() end },
		log = { levels = { WARN = 2, ERROR = 4, INFO = 1 } },
		notify = function(msg, level)
			table.insert(notify_calls, { msg = msg, level = level })
		end,
		cmd = function(c)
			table.insert(cmd_calls, c)
		end,
	}

	package.loaded["telescope"] = {
		extensions = {
			file_browser = {
				file_browser = function(opts)
					table.insert(extension_calls, { name = "file_browser.file_browser", opts = opts })
				end,
			},
		},
	}

	package.loaded["telescope.builtin"] = {
		git_files = function(opts)
			if fail_git_files then
				error("not a git repo")
			end
			table.insert(builtin_calls, { name = "git_files", opts = opts })
		end,
		find_files = record(builtin_calls, "find_files"),
		grep_string = record(builtin_calls, "grep_string"),
		live_grep = record(builtin_calls, "live_grep"),
		current_buffer_fuzzy_find = record(builtin_calls, "current_buffer_fuzzy_find"),
	}

	package.loaded["telescope.themes"] = {
		get_dropdown = function(opts)
			table.insert(theme_calls, { name = "get_dropdown", opts = opts })
			return { dropdown = true, opts = opts }
		end,
	}

	package.loaded["telescope.actions"] = {
		close = function() end,
	}
end

local function load_actions()
	package.loaded["plugins.telescope.actions"] = nil
	return dofile(actions_dir .. "actions.lua")
end

describe("plugins.telescope.actions", function()
	local saved_vim, saved_loaded

	setup(function()
		saved_vim = _G.vim
		saved_loaded = {
			telescope = package.loaded["telescope"],
			builtin = package.loaded["telescope.builtin"],
			themes = package.loaded["telescope.themes"],
			actions = package.loaded["telescope.actions"],
		}
	end)

	teardown(function()
		_G.vim = saved_vim
		package.loaded["telescope"] = saved_loaded.telescope
		package.loaded["telescope.builtin"] = saved_loaded.builtin
		package.loaded["telescope.themes"] = saved_loaded.themes
		package.loaded["telescope.actions"] = saved_loaded.actions
	end)

	before_each(function()
		setup_vim_mock()
	end)

	describe("project_files", function()
		it("uses git_files when the buffer is in a git repo", function()
			fail_git_files = false
			load_actions().project_files()
			assert.equals(1, #builtin_calls)
			assert.equals("git_files", builtin_calls[1].name)
		end)

		it("falls back to find_files when git_files errors", function()
			fail_git_files = true
			load_actions().project_files()
			assert.equals(1, #builtin_calls)
			assert.equals("find_files", builtin_calls[1].name)
		end)
	end)

	describe("grep_current_word", function()
		it("greps the word under the cursor", function()
			load_actions().grep_current_word()
			assert.equals(1, #builtin_calls)
			assert.equals("grep_string", builtin_calls[1].name)
			assert.equals("needle", builtin_calls[1].args[1].search)
		end)
	end)

	describe("grep_visual_selection", function()
		it("greps the joined visual selection text", function()
			load_actions().grep_visual_selection()
			assert.equals(1, #builtin_calls)
			assert.equals("grep_string", builtin_calls[1].name)
			assert.is_string(builtin_calls[1].args[1].search)
		end)
	end)

	describe("search_and_replace", function()
		it("returns early when the search term is empty", function()
			input_queue = { "", "" }
			load_actions().search_and_replace()
			assert.equals(0, #builtin_calls)
		end)

		it("returns early when the replace term is empty", function()
			input_queue = { "foo", "" }
			load_actions().search_and_replace()
			assert.equals(0, #builtin_calls)
		end)

		it("invokes grep_string with both terms reflected in the prompt title", function()
			input_queue = { "foo", "bar" }
			load_actions().search_and_replace()
			assert.equals(1, #builtin_calls)
			local call = builtin_calls[1]
			assert.equals("grep_string", call.name)
			assert.equals("foo", call.args[1].search)
			assert.truthy(call.args[1].prompt_title:find("foo"))
			assert.truthy(call.args[1].prompt_title:find("bar"))
			assert.is_function(call.args[1].attach_mappings)
		end)
	end)

	describe("grep_yanked_text", function()
		it("notifies and returns when the yank register is empty", function()
			_G.vim._yank = ""
			load_actions().grep_yanked_text()
			assert.equals(0, #builtin_calls)
			assert.equals(1, #notify_calls)
			assert.equals(_G.vim.log.levels.WARN, notify_calls[1].level)
		end)

		it("greps for the normalized yank contents", function()
			_G.vim._yank = "  some\n\nyanked\rtext  "
			load_actions().grep_yanked_text()
			assert.equals(1, #builtin_calls)
			assert.equals("grep_string", builtin_calls[1].name)
			-- Newlines/CRs collapse to spaces; leading/trailing whitespace stripped.
			assert.is_nil(builtin_calls[1].args[1].search:find("[\n\r]"))
			assert.equals("some", builtin_calls[1].args[1].search:match("^%S+"))
		end)
	end)

	describe("find_files_yanked", function()
		it("uses normalized yank content as the default text", function()
			_G.vim._yank = "  hello\nworld  "
			load_actions().find_files_yanked()
			assert.equals(1, #builtin_calls)
			assert.equals("find_files", builtin_calls[1].name)
			assert.equals("hello world", builtin_calls[1].args[1].default_text)
		end)
	end)

	describe("find_files_cwd", function()
		it("notifies when there is no current buffer", function()
			_G.vim._current_file = ""
			load_actions().find_files_cwd()
			assert.equals(0, #builtin_calls)
			assert.equals(1, #notify_calls)
		end)

		it("uses the current buffer's directory", function()
			_G.vim._current_file = "/home/u/proj/src/main.lua"
			load_actions().find_files_cwd()
			assert.equals(1, #builtin_calls)
			assert.equals("find_files", builtin_calls[1].name)
			assert.equals("/home/u/proj/src", builtin_calls[1].args[1].cwd)
			assert.truthy(builtin_calls[1].args[1].prompt_title:find("CWD"))
		end)
	end)

	describe("live_grep_cwd", function()
		it("notifies when there is no current buffer", function()
			_G.vim._current_file = ""
			load_actions().live_grep_cwd()
			assert.equals(0, #builtin_calls)
			assert.equals(1, #notify_calls)
		end)

		it("uses the current buffer's directory", function()
			_G.vim._current_file = "/home/u/proj/src/main.lua"
			load_actions().live_grep_cwd()
			assert.equals(1, #builtin_calls)
			assert.equals("live_grep", builtin_calls[1].name)
			assert.equals("/home/u/proj/src", builtin_calls[1].args[1].cwd)
		end)
	end)

	describe("current_buffer_fuzzy_find", function()
		it("uses the dropdown theme with previewer disabled", function()
			load_actions().current_buffer_fuzzy_find()
			assert.equals(1, #builtin_calls)
			assert.equals("current_buffer_fuzzy_find", builtin_calls[1].name)
			assert.equals(1, #theme_calls)
			assert.equals(false, theme_calls[1].opts.previewer)
			assert.equals(10, theme_calls[1].opts.winblend)
		end)
	end)

	describe("live_grep_open_files", function()
		it("limits live_grep to the open buffers", function()
			load_actions().live_grep_open_files()
			assert.equals(1, #builtin_calls)
			assert.equals("live_grep", builtin_calls[1].name)
			assert.is_true(builtin_calls[1].args[1].grep_open_files)
		end)
	end)

	describe("find_neovim_files", function()
		it("uses stdpath('config') as the cwd", function()
			load_actions().find_neovim_files()
			assert.equals(1, #builtin_calls)
			assert.equals("find_files", builtin_calls[1].name)
			assert.equals("/etc/nvim", builtin_calls[1].args[1].cwd)
		end)
	end)

	describe("file_browser_home", function()
		it("opens the file_browser extension at the home directory", function()
			load_actions().file_browser_home()
			assert.equals(1, #extension_calls)
			local call = extension_calls[1]
			assert.equals("file_browser.file_browser", call.name)
			assert.equals("~", call.opts.path)
			assert.equals("~", call.opts.cwd)
			assert.is_true(call.opts.hidden)
			assert.is_false(call.opts.respect_gitignore)
			assert.equals("normal", call.opts.initial_mode)
		end)
	end)

	describe("module shape", function()
		it("exports the documented public functions", function()
			local actions = load_actions()
			local expected = {
				"project_files",
				"grep_current_word",
				"grep_visual_selection",
				"search_and_replace",
				"grep_yanked_text",
				"find_files_yanked",
				"find_files_cwd",
				"live_grep_cwd",
				"current_buffer_fuzzy_find",
				"live_grep_open_files",
				"find_neovim_files",
				"file_browser_home",
			}
			for _, name in ipairs(expected) do
				assert.is_function(actions[name], name .. " should be exported")
			end
		end)
	end)
end)
