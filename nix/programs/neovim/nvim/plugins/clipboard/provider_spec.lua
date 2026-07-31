-- luacheck: globals describe it before_each after_each setup teardown assert

-- Resolve the absolute path to this spec's directory
local function get_spec_dir()
	local info = debug.getinfo(1, "S")
	local spec_file = info.source:gsub("^@", "")

	if not spec_file:match("^/") then
		local handle = io.popen("pwd")
		if handle then
			local cwd = handle:read("*l")
			handle:close()
			spec_file = cwd .. "/" .. spec_file
		end
	end

	return spec_file:match("(.*/)")
end

local spec_dir = get_spec_dir()

--- Build a minimal vim mock.
--- @param opts table: { wayland = bool, executables = table, wsl = bool }
local function setup_vim_mock(opts)
	opts = opts or {}
	local executables = opts.executables or {}

	_G.vim = {
		env = { WAYLAND_DISPLAY = opts.wayland },
		fn = {
			executable = function(name)
				return executables[name] and 1 or 0
			end,
			has = function(feature)
				return (feature == "wsl" and opts.wsl) and 1 or 0
			end,
		},
		g = {},
	}
end

local function load_provider()
	package.loaded["plugins.clipboard.provider"] = nil
	return dofile(spec_dir .. "provider.lua")
end

describe("clipboard provider", function()
	local original_vim

	setup(function()
		original_vim = _G.vim
	end)

	teardown(function()
		_G.vim = original_vim
	end)

	describe("detect", function()
		it("returns wayland when WAYLAND_DISPLAY and wl-clipboard are both present", function()
			setup_vim_mock({
				wayland = "wayland-0",
				executables = { ["wl-copy"] = true, ["wl-paste"] = true },
				wsl = true,
			})
			assert.equals("wayland", load_provider().detect())
		end)

		it("falls back to wsl-exe when WAYLAND_DISPLAY is unset", function()
			setup_vim_mock({
				executables = { ["wl-copy"] = true, ["wl-paste"] = true },
				wsl = true,
			})
			assert.equals("wsl-exe", load_provider().detect())
		end)

		it("falls back to wsl-exe when WAYLAND_DISPLAY is empty", function()
			setup_vim_mock({
				wayland = "",
				executables = { ["wl-copy"] = true, ["wl-paste"] = true },
				wsl = true,
			})
			assert.equals("wsl-exe", load_provider().detect())
		end)

		it("falls back to wsl-exe when wl-clipboard is not installed", function()
			setup_vim_mock({ wayland = "wayland-0", wsl = true })
			assert.equals("wsl-exe", load_provider().detect())
		end)

		it("falls back to wsl-exe when only wl-copy is installed", function()
			setup_vim_mock({
				wayland = "wayland-0",
				executables = { ["wl-copy"] = true },
				wsl = true,
			})
			assert.equals("wsl-exe", load_provider().detect())
		end)

		it("returns nil outside WSL without wayland", function()
			setup_vim_mock({})
			assert.is_nil(load_provider().detect())
		end)

		it("returns wayland outside WSL when wl-clipboard is usable", function()
			setup_vim_mock({
				wayland = "wayland-1",
				executables = { ["wl-copy"] = true, ["wl-paste"] = true },
			})
			assert.equals("wayland", load_provider().detect())
		end)
	end)

	describe("build", function()
		before_each(function()
			setup_vim_mock({})
		end)

		it("builds a wl-clipboard provider", function()
			local provider = load_provider().build("wayland")

			assert.equals("wl-clipboard", provider.name)
			assert.same({ "wl-copy", "--type", "text/plain" }, provider.copy["+"])
			assert.same({ "wl-paste", "--no-newline", "--type", "text/plain" }, provider.paste["+"])
			assert.same({ "wl-copy", "--primary", "--type", "text/plain" }, provider.copy["*"])
			assert.equals(0, provider.cache_enabled)
		end)

		it("builds a clip.exe / powershell.exe provider", function()
			local provider = load_provider().build("wsl-exe")

			assert.equals("wsl-clipboard", provider.name)
			assert.truthy(provider.copy["+"][3]:match("clip%.exe"))
			assert.truthy(provider.paste["+"][3]:match("powershell%.exe"))
			assert.same(provider.copy["+"], provider.copy["*"])
			assert.same(provider.paste["+"], provider.paste["*"])
			assert.equals(0, provider.cache_enabled)
		end)

		it("returns nil for an unknown kind", function()
			assert.is_nil(load_provider().build(nil))
		end)
	end)

	describe("setup", function()
		it("assigns vim.g.clipboard when a provider is detected", function()
			setup_vim_mock({
				wayland = "wayland-0",
				executables = { ["wl-copy"] = true, ["wl-paste"] = true },
			})
			load_provider().setup()

			assert.equals("wl-clipboard", _G.vim.g.clipboard.name)
		end)

		it("leaves vim.g.clipboard untouched when nothing is detected", function()
			setup_vim_mock({})
			load_provider().setup()

			assert.is_nil(_G.vim.g.clipboard)
		end)
	end)
end)
