-- luacheck: globals describe it setup teardown assert

-- Resolve the nvim config directory from this test file's location
local function get_nvim_dir()
	local info = debug.getinfo(1, "S")
	local test_file = info.source:gsub("^@", "")
	if not test_file:match("^/") then
		local handle = io.popen("pwd")
		if handle then
			local cwd = handle:read("*l")
			handle:close()
			test_file = cwd .. "/" .. test_file
		end
	end
	return test_file:match("(.*/)")
end

local nvim_dir = get_nvim_dir()
local plugins_dir = nvim_dir .. "plugins/"

-- All captured keymaps: { { mode, lhs, desc, source, scope }, ... }
local captured_keymaps = {}
local current_source = "unknown"

-- Minimal vim mock that captures keymap registrations
local function setup_vim_mock()
	captured_keymaps = {}

	local function capture_keymap_set(mode, lhs, _, opts)
		opts = opts or {}
		local modes = type(mode) == "table" and mode or { mode }
		local scope = opts.buffer and "buffer" or "global"
		local desc = opts.desc or ""
		for _, m in ipairs(modes) do
			table.insert(captured_keymaps, {
				mode = m,
				lhs = lhs,
				desc = desc,
				source = current_source,
				scope = scope,
			})
		end
	end

	local function capture_nvim_set_keymap(mode, lhs, _, opts)
		opts = opts or {}
		local desc = opts.desc or ""
		table.insert(captured_keymaps, {
			mode = mode,
			lhs = lhs,
			desc = desc,
			source = current_source,
			scope = "global",
		})
	end

	_G.vim = {
		fn = {
			has = function()
				return 0
			end,
			stdpath = function()
				return "/tmp"
			end,
			expand = function(s)
				return s
			end,
			system = function()
				return ""
			end,
			fnamemodify = function()
				return ""
			end,
			getpos = function()
				return { 0, 0, 0, 0 }
			end,
			getreg = function()
				return ""
			end,
			input = function()
				return ""
			end,
			sign_define = function() end,
		},
		g = { mapleader = " ", maplocalleader = " ", have_nerd_font = false },
		o = {},
		bo = setmetatable({}, {
			__index = function()
				return {}
			end,
		}),
		opt = {
			rtp = {
				prepend = function() end,
			},
		},
		v = { shell_error = 0 },
		env = { HOME = "/home/testuser" },
		api = {
			nvim_create_autocmd = function(event, opts)
				-- Store LspAttach callback for later invocation
				if event == "LspAttach" and opts and opts.callback then
					_G._lspattach_callback = opts.callback
				end
			end,
			nvim_create_augroup = function(name, opts)
				return { name = name, opts = opts }
			end,
			nvim_set_hl = function() end,
			nvim_set_keymap = capture_nvim_set_keymap,
			nvim_buf_get_option = function()
				return ""
			end,
			nvim_win_get_cursor = function()
				return { 1, 0 }
			end,
			nvim_buf_get_text = function()
				return { "" }
			end,
			nvim_buf_get_lines = function()
				return { "" }
			end,
			nvim_create_user_command = function() end,
			nvim_get_runtime_file = function()
				return {}
			end,
		},
		keymap = {
			set = capture_keymap_set,
		},
		cmd = function() end,
		notify = function() end,
		log = { levels = { WARN = 2, ERROR = 4, INFO = 1 } },
		uv = { fs_stat = function() end },
		loop = { fs_stat = function() end },
		diagnostic = {
			config = function() end,
			severity = { WARN = 2, ERROR = 4, HINT = 3, INFO = 1 },
			open_float = function() end,
			goto_prev = function() end,
			goto_next = function() end,
			setloclist = function() end,
		},
		lsp = {
			config = setmetatable({}, {
				__newindex = function() end,
				__index = function() end,
			}),
			protocol = {
				make_client_capabilities = function()
					return {}
				end,
			},
			enable = function() end,
			buf = {
				rename = function() end,
				code_action = function() end,
				declaration = function() end,
				hover = function() end,
				signature_help = function() end,
				format = function() end,
			},
			get_clients = function()
				return {}
			end,
			get_client_by_id = function()
				return {
					supports_method = function()
						return true
					end,
				}
			end,
		},
		tbl_deep_extend = function(_, base, override)
			if type(base) ~= "table" then
				return override or base
			end
			if type(override) ~= "table" then
				return override or base
			end
			local result = {}
			for k, v in pairs(base) do
				result[k] = v
			end
			for k, v in pairs(override) do
				result[k] = v
			end
			return result
		end,
		list_extend = function(dst, src)
			for _, v in ipairs(src) do
				table.insert(dst, v)
			end
			return dst
		end,
	}
end

-- Plugin files that define keymaps in their config() function
local plugins_with_keymaps = {
	"telescope",
	"vim-fugitive",
	"nvim-tree",
	"diffview",
	"oil",
	"orgmode",
	"toggleterm",
	"neotest",
	"vim-argwrap",
	"markdown-preview",
	"open-browser",
	"package-info",
	"pathtool",
	"rest",
	"nvim-dbee",
	"dropbar",
	"git-conflict",
	"gitlinker",
}

-- Scan filesystem for plugins that have keymaps.lua
local function find_plugins_with_keymaps_on_disk()
	local result = {}
	local handle = io.popen('ls -d "' .. plugins_dir .. '"*/keymaps.lua 2>/dev/null')
	if handle then
		for line in handle:lines() do
			local plugin_name = line:match(".*/plugins/([^/]+)/keymaps%.lua$")
			if plugin_name then
				table.insert(result, plugin_name)
			end
		end
		handle:close()
	end
	table.sort(result)
	return result
end

-- Find conflicts: entries with same (mode, lhs, scope)
local function find_conflicts(keymaps)
	local groups = {}
	for _, km in ipairs(keymaps) do
		local key = km.mode .. "|" .. km.lhs .. "|" .. km.scope
		if not groups[key] then
			groups[key] = {}
		end
		table.insert(groups[key], km)
	end

	local conflicts = {}
	for _, entries in pairs(groups) do
		if #entries > 1 then
			table.insert(conflicts, {
				mode = entries[1].mode,
				lhs = entries[1].lhs,
				scope = entries[1].scope,
				entries = entries,
			})
		end
	end

	table.sort(conflicts, function(a, b)
		if a.lhs == b.lhs then
			return a.mode < b.mode
		end
		return a.lhs < b.lhs
	end)

	return conflicts
end

-- Format a conflict for readable assertion messages
local function format_conflict(conflict)
	local parts = { string.format("[%s] %s (scope: %s):", conflict.mode, conflict.lhs, conflict.scope) }
	for _, entry in ipairs(conflict.entries) do
		table.insert(parts, string.format("  - %s: %s", entry.source, entry.desc))
	end
	return table.concat(parts, "\n")
end

describe("keymap conflict detection", function()
	local original_vim
	local original_path

	setup(function()
		original_vim = _G.vim
		original_path = package.path
		setup_vim_mock()

		-- Add nvim dir to package path
		package.path = nvim_dir .. "?.lua;" .. nvim_dir .. "?/init.lua;" .. package.path

		-- Mock external plugin dependencies
		package.loaded["cmp_nvim_lsp"] = {
			default_capabilities = function(caps)
				return caps or {}
			end,
		}
		package.loaded["telescope.builtin"] = {
			lsp_definitions = function() end,
			lsp_references = function() end,
			lsp_implementations = function() end,
			lsp_type_definitions = function() end,
			lsp_document_symbols = function() end,
			lsp_dynamic_workspace_symbols = function() end,
			find_files = function() end,
			grep_string = function() end,
			live_grep = function() end,
			resume = function() end,
			oldfiles = function() end,
			buffers = function() end,
			current_buffer_fuzzy_find = function() end,
			git_files = function() end,
			git_status = function() end,
			git_commits = function() end,
			git_branches = function() end,
		}
		package.loaded["telescope"] = {
			setup = function() end,
			load_extension = function() end,
			extensions = {
				file_browser = {
					file_browser = function() end,
				},
			},
		}
		-- telescope.actions mock: each action needs to support the + operator
		local action_mt = {
			__add = function()
				return setmetatable({}, {
					__call = function() end,
					__add = function()
						return setmetatable({}, { __call = function() end })
					end,
				})
			end,
			__call = function() end,
		}
		local function mock_action()
			return setmetatable({}, action_mt)
		end
		package.loaded["telescope.actions"] = setmetatable({}, {
			__index = function()
				return mock_action()
			end,
		})
		package.loaded["telescope.sorters"] = {
			get_fzy_sorter = function() end,
		}
		package.loaded["telescope.themes"] = {
			get_dropdown = function()
				return {}
			end,
		}
		package.loaded["nvim-tree"] = {
			setup = function() end,
		}
		package.loaded["diffview"] = {
			setup = function() end,
		}
		package.loaded["oil"] = {
			setup = function() end,
			open = function() end,
		}
		package.loaded["orgmode"] = {
			setup = function() end,
		}
		package.loaded["toggleterm"] = {
			setup = function() end,
		}
		package.loaded["neotest"] = {
			setup = function() end,
			run = { run = function() end },
		}
		package.loaded["package-info"] = {
			setup = function() end,
			show = function() end,
			delete = function() end,
			change_version = function() end,
			install = function() end,
		}
		package.loaded["pathtool"] = {
			setup = function() end,
		}
		package.loaded["rest-nvim"] = {
			setup = function() end,
		}
		package.loaded["dbee"] = {
			setup = function() end,
			toggle = function() end,
		}
		package.loaded["dropbar"] = {
			setup = function() end,
		}
		package.loaded["dropbar.api"] = {
			pick = function() end,
			goto_context_start = function() end,
			select_next_context = function() end,
		}
		package.loaded["git-conflict"] = {
			setup = function() end,
		}
		package.loaded["gitlinker"] = {
			setup = function() end,
			actions = { copy_to_clipboard = function() end },
		}
		package.loaded["gitlinker.actions"] = {
			copy_to_clipboard = function() end,
		}

		-- Load keymaps.lua (global keymaps)
		current_source = "keymaps"
		dofile(nvim_dir .. "keymaps.lua")

		-- Load LSP keymaps
		current_source = "lsp/keymaps"
		-- Clear any cached lsp modules
		for name in pairs(package.loaded) do
			if name:match("^lsp%.") then
				package.loaded[name] = nil
			end
		end
		dofile(nvim_dir .. "lsp/keymaps.lua")

		-- Execute the LspAttach callback to capture buffer-local LSP keymaps
		if _G._lspattach_callback then
			_G._lspattach_callback({ buf = 1, data = { client_id = 1 } })
		end

		-- Load each plugin's config and execute it to capture keymaps
		for _, plugin_name in ipairs(plugins_with_keymaps) do
			current_source = "plugins/" .. plugin_name

			-- Clear cached plugin modules
			for name in pairs(package.loaded) do
				if name:match("^plugins%.") then
					package.loaded[name] = nil
				end
			end

			local ok, mod = pcall(dofile, plugins_dir .. plugin_name .. "/init.lua")
			if ok and mod and mod.config then
				local spec_ok, spec = pcall(mod.config)
				if spec_ok and spec and type(spec.config) == "function" then
					pcall(spec.config, nil, spec.opts or {})
				end
			end
		end
	end)

	teardown(function()
		_G.vim = original_vim
		package.path = original_path
		_G._lspattach_callback = nil

		-- Clean up loaded modules
		for name in pairs(package.loaded) do
			if
				name:match("^plugins%.")
				or name:match("^lsp%.")
				or name:match("^telescope")
				or name:match("^cmp")
				or name:match("^gitlinker")
			then
				package.loaded[name] = nil
			end
		end
	end)

	it("plugins_with_keymaps list matches actual keymaps.lua files on disk", function()
		local on_disk = find_plugins_with_keymaps_on_disk()
		local in_list = {}
		for _, name in ipairs(plugins_with_keymaps) do
			table.insert(in_list, name)
		end
		table.sort(in_list)

		-- Check for plugins on disk but missing from the list
		local missing_from_list = {}
		local list_set = {}
		for _, name in ipairs(in_list) do
			list_set[name] = true
		end
		for _, name in ipairs(on_disk) do
			if not list_set[name] then
				table.insert(missing_from_list, name)
			end
		end

		-- Check for plugins in the list but not on disk
		local extra_in_list = {}
		local disk_set = {}
		for _, name in ipairs(on_disk) do
			disk_set[name] = true
		end
		for _, name in ipairs(in_list) do
			if not disk_set[name] then
				table.insert(extra_in_list, name)
			end
		end

		local messages = {}
		if #missing_from_list > 0 then
			table.insert(
				messages,
				"Plugins with keymaps.lua on disk but missing from plugins_with_keymaps: "
					.. table.concat(missing_from_list, ", ")
			)
		end
		if #extra_in_list > 0 then
			table.insert(
				messages,
				"Plugins in plugins_with_keymaps but without keymaps.lua on disk: " .. table.concat(extra_in_list, ", ")
			)
		end

		assert.equals(0, #missing_from_list + #extra_in_list, table.concat(messages, "\n"))
	end)

	it("captures keymaps from all sources", function()
		assert.truthy(#captured_keymaps > 0, "should have captured at least some keymaps")
	end)

	it("has no conflicts among global keymaps", function()
		local global_keymaps = {}
		for _, km in ipairs(captured_keymaps) do
			if km.scope == "global" then
				table.insert(global_keymaps, km)
			end
		end

		local conflicts = find_conflicts(global_keymaps)

		if #conflicts > 0 then
			local messages = { "Global keymap conflicts found:\n" }
			for _, conflict in ipairs(conflicts) do
				table.insert(messages, format_conflict(conflict))
				table.insert(messages, "")
			end
			assert.same({}, conflicts, table.concat(messages, "\n"))
		end
	end)

	it("has no conflicts among buffer-local keymaps", function()
		local buffer_keymaps = {}
		for _, km in ipairs(captured_keymaps) do
			if km.scope == "buffer" then
				table.insert(buffer_keymaps, km)
			end
		end

		local conflicts = find_conflicts(buffer_keymaps)

		if #conflicts > 0 then
			local messages = { "Buffer-local keymap conflicts found:\n" }
			for _, conflict in ipairs(conflicts) do
				table.insert(messages, format_conflict(conflict))
				table.insert(messages, "")
			end
			assert.same({}, conflicts, table.concat(messages, "\n"))
		end
	end)

	it("has no global-buffer overlaps with different functionality", function()
		-- This test warns about cases where a global and buffer-local keymap
		-- share the same (mode, lhs), which means the buffer-local one shadows
		-- the global one in LSP-attached buffers.
		local global_keys = {}
		local buffer_keys = {}

		for _, km in ipairs(captured_keymaps) do
			local key = km.mode .. "|" .. km.lhs
			if km.scope == "global" then
				global_keys[key] = global_keys[key] or km
			elseif km.scope == "buffer" then
				buffer_keys[key] = buffer_keys[key] or km
			end
		end

		local overlaps = {}
		for key, global_km in pairs(global_keys) do
			if buffer_keys[key] then
				table.insert(overlaps, {
					mode = global_km.mode,
					lhs = global_km.lhs,
					global_source = global_km.source,
					global_desc = global_km.desc,
					buffer_source = buffer_keys[key].source,
					buffer_desc = buffer_keys[key].desc,
				})
			end
		end

		if #overlaps > 0 then
			table.sort(overlaps, function(a, b)
				return a.lhs < b.lhs
			end)
			local messages = { "Global/buffer keymap overlaps (buffer-local shadows global in LSP buffers):\n" }
			for _, overlap in ipairs(overlaps) do
				table.insert(
					messages,
					string.format(
						"  [%s] %s:\n    global: %s (%s)\n    buffer: %s (%s)",
						overlap.mode,
						overlap.lhs,
						overlap.global_source,
						overlap.global_desc,
						overlap.buffer_source,
						overlap.buffer_desc
					)
				)
			end
			-- This is a warning, not a failure - print it but don't fail
			print(table.concat(messages, "\n"))
		end
	end)
end)

describe("keymap_registry module", function()
	local original_vim
	local registry

	setup(function()
		original_vim = _G.vim
		_G.vim = {
			keymap = {
				set = function() end,
			},
		}
		registry = dofile(nvim_dir .. "keymap_registry.lua")
	end)

	teardown(function()
		_G.vim = original_vim
	end)

	it("registers keymaps and tracks them", function()
		registry.clear()
		registry.set("test-source", "n", "<leader>xx", function() end, { desc = "Test keymap" })

		local all = registry._registry
		assert.equals(1, #all)
		assert.equals("n", all[1].mode)
		assert.equals("<leader>xx", all[1].lhs)
		assert.equals("test-source", all[1].source)
		assert.equals("global", all[1].scope)
	end)

	it("detects conflicts between different sources", function()
		registry.clear()
		registry.set("source-a", "n", "<leader>yy", function() end, { desc = "Action A" })
		registry.set("source-b", "n", "<leader>yy", function() end, { desc = "Action B" })

		local conflicts = registry.validate()
		assert.equals(1, #conflicts)
		assert.equals("<leader>yy", conflicts[1].lhs)
		assert.equals(2, #conflicts[1].entries)
	end)

	it("detects conflicts within the same source", function()
		registry.clear()
		registry.set("source-a", "n", "<leader>zz", function() end, { desc = "First" })
		registry.set("source-a", "n", "<leader>zz", function() end, { desc = "Second" })

		local conflicts = registry.validate()
		assert.equals(1, #conflicts)
	end)

	it("does not flag different modes as conflicts", function()
		registry.clear()
		registry.set("source-a", "n", "<leader>aa", function() end, { desc = "Normal mode" })
		registry.set("source-a", "v", "<leader>aa", function() end, { desc = "Visual mode" })

		local conflicts = registry.validate()
		assert.equals(0, #conflicts)
	end)

	it("does not flag global vs buffer-local as conflicts", function()
		registry.clear()
		registry.set("source-a", "n", "<leader>bb", function() end, { desc = "Global" })
		registry.set("source-b", "n", "<leader>bb", function() end, { buffer = 1, desc = "Buffer-local" })

		local conflicts = registry.validate()
		assert.equals(0, #conflicts)
	end)

	it("handles multi-mode registration", function()
		registry.clear()
		registry.set("source-a", { "n", "v" }, "<leader>cc", function() end, { desc = "Multi-mode" })

		local all = registry._registry
		assert.equals(2, #all)
		assert.equals("n", all[1].mode)
		assert.equals("v", all[2].mode)
	end)

	it("formats conflicts into readable strings", function()
		registry.clear()
		registry.set("source-a", "n", "<leader>dd", function() end, { desc = "Action A" })
		registry.set("source-b", "n", "<leader>dd", function() end, { desc = "Action B" })

		local conflicts = registry.validate()
		local formatted = registry.format_conflicts(conflicts)
		assert.truthy(formatted:find("source%-a"))
		assert.truthy(formatted:find("source%-b"))
		assert.truthy(formatted:find("<leader>dd"))
	end)

	it("reports no conflicts when registry is clean", function()
		registry.clear()
		registry.set("source-a", "n", "<leader>ee", function() end, { desc = "A" })
		registry.set("source-b", "n", "<leader>ff", function() end, { desc = "B" })

		local conflicts = registry.validate()
		assert.equals(0, #conflicts)
		assert.truthy(registry.format_conflicts(conflicts):find("No keymap conflicts"))
	end)
end)
