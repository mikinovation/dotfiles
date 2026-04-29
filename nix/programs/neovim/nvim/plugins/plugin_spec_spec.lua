-- luacheck: globals describe it before_each after_each setup teardown assert

-- Resolve the absolute path to the plugins directory
local function get_plugins_dir()
	-- Use the test file's own location to find the plugins directory
	local info = debug.getinfo(1, "S")
	local test_file = info.source:gsub("^@", "")

	-- If relative path, prepend cwd
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

local plugins_dir = get_plugins_dir()

-- Minimal vim mock for loading plugin specs without Neovim runtime
local function setup_vim_mock()
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
			fnamemodify = function(_, _)
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
		},
		g = { mapleader = " ", maplocalleader = " ", have_nerd_font = false },
		o = {},
		opt = {
			rtp = {
				prepend = function() end,
			},
		},
		v = { shell_error = 0 },
		api = {
			nvim_create_autocmd = function() end,
			nvim_set_hl = function() end,
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
		},
		keymap = {
			set = function() end,
		},
		cmd = function() end,
		notify = function() end,
		log = { levels = { WARN = 2, ERROR = 4, INFO = 1 } },
		uv = { fs_stat = function() end },
		loop = { fs_stat = function() end },
	}
end

-- Load a plugin file using dofile (avoids require path issues)
local function load_plugin(name)
	local filepath = plugins_dir .. name .. "/init.lua"
	return dofile(filepath)
end

-- All plugin files (excluding this test and clipboard which has a different pattern)
local lazy_plugin_files = {
	"cmp-buffer",
	"cmp-cmdline",
	"cmp-luasnip",
	"cmp-nvim-lsp",
	"cmp-path",
	"comment",
	"copilot",
	"copilot-cmp",
	"diffview",
	"dropbar",
	"fidget",
	"fixcursorhold",
	"friendly-snippets",
	"git-conflict",
	"gitlinker",
	"gitsigns",
	"indent-blankline",
	"lazydev",
	"lspkind",
	"lualine",
	"luasnip",
	"markdown-preview",
	"neogit",
	"neotest",
	"neotest-rust",
	"neotest-vitest",
	"none-ls",
	"none-ls-extras",
	"nui",
	"nvim-autopairs",
	"nvim-bqf",
	"nvim-cmp",
	"nvim-colorizer",
	"nvim-context-vt",
	"nvim-dap",
	"nvim-dap-ui",
	"nvim-dap-virtual-text",
	"nvim-dap-vscode-js",
	"nvim-dbee",
	"nvim-nio",
	"nvim-notify",
	"nvim-tree",
	"nvim-treesitter",
	"nvim-treesitter-context",
	"nvim-ts-autotag",
	"nvim-ts-context-commentstring",
	"nvim-web-devicons",
	"octo",
	"oil",
	"open-browser",
	"org-bullets",
	"org-roam",
	"orgmode",
	"package-info",
	"pathtool",
	"plenary",
	"quick-scope",
	"rest",
	"sqlite",
	"telescope",
	"telescope-file-browser",
	"telescope-frecency",
	"telescope-fzf-native",
	"telescope-media-files",
	"telescope-project",
	"telescope-repo",
	"telescope-ui-select",
	"todo-comments",
	"toggleterm",
	"tokyonight",
	"tsc",
	"vim-argwrap",
	"vim-bundler",
	"vim-fugitive",
	"vim-illuminate",
	"vim-matchup",
	"vim-rails",
	"vim-sleuth",
	"vscode-js-debug",
	"which-key",
	"yanky",
}

describe("plugin specs", function()
	local original_vim

	setup(function()
		original_vim = _G.vim
		setup_vim_mock()

		-- Add nvim config directory to package.path so require("plugins.xxx") works
		-- from within plugin files that load dependencies
		local nvim_dir = plugins_dir:match("(.*/nix/programs/neovim/nvim/)")
		if nvim_dir then
			package.path = nvim_dir .. "?.lua;" .. nvim_dir .. "?/init.lua;" .. package.path
		end
	end)

	teardown(function()
		_G.vim = original_vim

		for key, _ in pairs(package.loaded) do
			if key:match("^plugins%.") then
				package.loaded[key] = nil
			end
		end
	end)

	for _, plugin_name in ipairs(lazy_plugin_files) do
		describe(plugin_name, function()
			it("returns a table with a config function", function()
				local mod = load_plugin(plugin_name)
				assert.is_table(mod, plugin_name .. " must return a table")
				assert.is_function(mod.config, plugin_name .. " must have a config function")
			end)

			it("config() returns a valid lazy.nvim spec", function()
				local mod = load_plugin(plugin_name)
				local spec = mod.config()
				assert.is_table(spec, plugin_name .. ": config() must return a table")

				-- lazy.nvim spec must have a plugin name at index [1]
				assert.is_string(spec[1], plugin_name .. ": spec[1] must be a string (e.g. 'author/repo')")
				assert.truthy(
					spec[1]:match(".+/.+"),
					plugin_name .. ": spec[1] '" .. spec[1] .. "' should be in 'author/repo' format"
				)
			end)

			it("optional fields have correct types", function()
				local mod = load_plugin(plugin_name)
				local spec = mod.config()

				if spec.config ~= nil then
					local t = type(spec.config)
					-- lazy.nvim accepts both function and boolean (true = auto setup())
					assert.truthy(
						t == "function" or t == "boolean",
						plugin_name .. ": spec.config must be a function or boolean, got " .. t
					)
				end

				if spec.dependencies ~= nil then
					assert.is_table(spec.dependencies, plugin_name .. ": spec.dependencies must be a table")
				end

				if spec.event ~= nil then
					local t = type(spec.event)
					assert.truthy(
						t == "string" or t == "table",
						plugin_name .. ": spec.event must be a string or table, got " .. t
					)
				end

				if spec.ft ~= nil then
					local t = type(spec.ft)
					assert.truthy(
						t == "string" or t == "table",
						plugin_name .. ": spec.ft must be a string or table, got " .. t
					)
				end

				if spec.cmd ~= nil then
					local t = type(spec.cmd)
					assert.truthy(
						t == "string" or t == "table",
						plugin_name .. ": spec.cmd must be a string or table, got " .. t
					)
				end

				if spec.keys ~= nil then
					local t = type(spec.keys)
					assert.truthy(
						t == "string" or t == "table",
						plugin_name .. ": spec.keys must be a string or table, got " .. t
					)
				end

				if spec.opts ~= nil then
					assert.is_table(spec.opts, plugin_name .. ": spec.opts must be a table")
				end
			end)
		end)
	end
end)

describe("plugin file coverage", function()
	local excluded = { clipboard = true }

	it("all plugin directories are covered by the test list", function()
		local covered = {}
		for _, name in ipairs(lazy_plugin_files) do
			covered[name] = true
		end

		local handle = io.popen("ls -d " .. plugins_dir .. "*/")
		if not handle then
			error("failed to list plugin directory")
		end
		local result = handle:read("*a")
		handle:close()

		local missing = {}
		for dir in result:gmatch("[^\n]+") do
			local name = dir:match("([^/]+)/$")
			if name and not covered[name] and not excluded[name] then
				table.insert(missing, name)
			end
		end

		assert.same({}, missing, "Plugin directories not covered by tests: " .. table.concat(missing, ", "))
	end)
end)

describe("clipboard plugin", function()
	local original_vim

	setup(function()
		original_vim = _G.vim
		setup_vim_mock()
	end)

	teardown(function()
		_G.vim = original_vim
	end)

	it("returns a table with a config function", function()
		local mod = load_plugin("clipboard")
		assert.is_table(mod)
		assert.is_function(mod.config)
	end)

	it("config() executes without error", function()
		local mod = load_plugin("clipboard")
		assert.has_no.errors(function()
			mod.config()
		end)
	end)
end)
