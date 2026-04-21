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

describe("plugins.gitlinker.actions", function()
	local saved_gitlinker
	local get_buf_range_url_calls

	setup(function()
		saved_gitlinker = package.loaded["gitlinker"]
	end)

	teardown(function()
		package.loaded["gitlinker"] = saved_gitlinker
	end)

	before_each(function()
		get_buf_range_url_calls = {}
		package.loaded["gitlinker"] = {
			get_buf_range_url = function(mode)
				table.insert(get_buf_range_url_calls, mode)
			end,
		}
	end)

	describe("copy_git_link", function()
		it("calls gitlinker.get_buf_range_url with normal mode", function()
			local actions = dofile(actions_dir .. "actions.lua")
			actions.copy_git_link()
			assert.equals(1, #get_buf_range_url_calls)
			assert.equals("n", get_buf_range_url_calls[1])
		end)
	end)

	describe("module shape", function()
		it("exports copy_git_link", function()
			local actions = dofile(actions_dir .. "actions.lua")
			assert.is_function(actions.copy_git_link)
		end)
	end)
end)
