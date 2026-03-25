-- lsp/test_helper.lua
-- Shared test utilities for LSP spec files

local M = {}

-- Resolve the lsp directory from the calling spec file
function M.get_lsp_dir()
	local info = debug.getinfo(2, "S")
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

-- Set nvim_dir from caller (each spec passes its resolved directory)
function M.init(lsp_dir)
	M.nvim_dir = lsp_dir:match("(.*/)[^/]+/$")
end

-- Save global state before tests (call in busted setup())
function M.save_state()
	M._saved = {
		vim = _G.vim,
		cmp_nvim_lsp = package.loaded["cmp_nvim_lsp"],
		telescope_builtin = package.loaded["telescope.builtin"],
	}
end

-- Restore global state after tests (call in busted teardown())
function M.restore_state()
	if M._saved then
		_G.vim = M._saved.vim
		package.loaded["cmp_nvim_lsp"] = M._saved.cmp_nvim_lsp
		package.loaded["telescope.builtin"] = M._saved.telescope_builtin
		M._saved = nil
	end
end

-- State captured from lsp module execution
M.captured = {}

-- Recursive deep merge (mirrors vim.tbl_deep_extend behavior)
local function deep_merge(base, override)
	local result = {}
	for k, v in pairs(base) do
		if type(v) == "table" and type(override[k]) == "table" then
			result[k] = deep_merge(v, override[k])
		else
			result[k] = v
		end
	end
	for k, v in pairs(override) do
		if result[k] == nil then
			result[k] = v
		end
	end
	return result
end

function M.setup_vim_mock()
	M.captured = {
		autocmds = {},
		diagnostic_config = nil,
		signs_defined = {},
		lsp_servers_enabled = {},
	}

	-- Mock require for external dependencies
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
	}

	-- Metatable-based lsp.config to capture server configurations
	local lsp_config_store = {}
	local lsp_config_mt = {
		__newindex = function(_, key, value)
			lsp_config_store[key] = value
		end,
		__index = function(_, key)
			return lsp_config_store[key]
		end,
	}

	_G.vim = {
		fn = {
			has = function()
				return 0
			end,
			sign_define = function(name, opts)
				M.captured.signs_defined[name] = opts
			end,
		},
		g = { mapleader = " ", maplocalleader = " " },
		o = {},
		bo = setmetatable({}, {
			__index = function()
				return {}
			end,
		}),
		opt = {},
		env = { HOME = "/home/testuser" },
		api = {
			nvim_create_autocmd = function(event, opts)
				table.insert(M.captured.autocmds, { event = event, opts = opts })
			end,
			nvim_create_augroup = function(name, opts)
				return { name = name, opts = opts }
			end,
			nvim_get_runtime_file = function()
				return {}
			end,
		},
		keymap = {
			set = function() end,
		},
		cmd = function() end,
		notify = function() end,
		log = { levels = { WARN = 2, ERROR = 4, INFO = 1 } },
		diagnostic = {
			config = function(opts)
				M.captured.diagnostic_config = opts
			end,
			severity = { WARN = 2, ERROR = 4, HINT = 3, INFO = 1 },
			open_float = function() end,
			goto_prev = function() end,
			goto_next = function() end,
			setloclist = function() end,
		},
		lsp = {
			config = setmetatable({}, lsp_config_mt),
			protocol = {
				make_client_capabilities = function()
					return {}
				end,
			},
			enable = function(servers)
				M.captured.lsp_servers_enabled = servers
			end,
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
		},
		tbl_deep_extend = function(_, base, override)
			return deep_merge(base, override)
		end,
		list_extend = function(dst, src)
			for _, v in ipairs(src) do
				table.insert(dst, v)
			end
			return dst
		end,
	}

	-- Store reference for assertions
	M.captured.lsp_config_store = lsp_config_store
end

function M.load_lsp()
	-- Ensure lsp submodules can be re-required on each test run
	package.loaded["lsp.keymaps"] = nil
	package.loaded["lsp.diagnostics"] = nil
	package.loaded["lsp.servers"] = nil
	package.loaded["lsp.servers.lua_ls"] = nil
	package.loaded["lsp.servers.rust_analyzer"] = nil
	package.loaded["lsp.servers.typescript"] = nil
	package.loaded["lsp.servers.tailwindcss"] = nil
	package.loaded["lsp.servers.solargraph"] = nil

	-- Add nvim dir to package path so require("lsp.xxx") resolves correctly
	local nvim_path = M.nvim_dir .. "?.lua"
	local nvim_init_path = M.nvim_dir .. "?/init.lua"
	if not package.path:find(nvim_path, 1, true) then
		package.path = nvim_path .. ";" .. nvim_init_path .. ";" .. package.path
	end

	return dofile(M.nvim_dir .. "lsp/init.lua")
end

return M
