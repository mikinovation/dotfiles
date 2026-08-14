-- luacheck: globals describe it before_each after_each assert

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

local module_dir = spec_dir()

local function load_module()
	package.loaded["plugins.sidekick.skills_completion"] = nil
	return dofile(module_dir .. "skills_completion.lua")
end

--- Create an empty temporary directory; the caller removes it.
local function make_dir()
	local dir = os.tmpname()
	os.remove(dir)
	os.execute("mkdir -p " .. dir)
	return dir
end

local function write_file(path, contents)
	local file = assert(io.open(path, "w"))
	file:write(contents)
	file:close()
end

--- Create a skill directory holding `contents` as its SKILL.md.
--- Returns the directory path; the caller removes it.
local function make_skill_dir(contents)
	local dir = make_dir()
	write_file(dir .. "/SKILL.md", contents)
	return dir
end

--- A `vim.loop` good enough for M.cache_key and M.scan, backed by the real
--- filesystem through LuaFileSystem (busted runs without luv). lfs reports
--- mtimes in whole seconds, so the tests below assert on paths appearing and
--- disappearing from the key rather than on mtime resolution.
local function real_loop()
	local lfs = require("lfs")
	return {
		fs_stat = function(path)
			local attrs = lfs.attributes(path)
			if not attrs then
				return nil
			end
			return { mtime = { sec = attrs.modification, nsec = 0 } }
		end,
		fs_scandir = function(path)
			if lfs.attributes(path, "mode") ~= "directory" then
				return nil
			end
			local iterator, state = lfs.dir(path)
			return { iterator = iterator, state = state, path = path }
		end,
		fs_scandir_next = function(handle)
			while true do
				local name = handle.iterator(handle.state)
				if not name then
					return nil
				end
				if name ~= "." and name ~= ".." then
					local mode = lfs.attributes(handle.path .. "/" .. name, "mode")
					return name, mode == "directory" and "directory" or "file"
				end
			end
		end,
	}
end

describe("plugins.sidekick.skills_completion", function()
	describe("parse_frontmatter", function()
		local skills = load_module()

		it("extracts name and description", function()
			local result =
				skills.parse_frontmatter("---\nname: nix-npm-update\ndescription: nix の npm 更新\n---\n\n# body\n")
			assert.equals("nix-npm-update", result.name)
			assert.equals("nix の npm 更新", result.description)
		end)

		it("keeps colons inside the description", function()
			local result = skills.parse_frontmatter("---\ndescription: Use when: X happens\n---\n")
			assert.equals("Use when: X happens", result.description)
		end)

		it("strips surrounding quotes", function()
			local result = skills.parse_frontmatter("---\nname: \"quoted\"\ndescription: 'single'\n---\n")
			assert.equals("quoted", result.name)
			assert.equals("single", result.description)
		end)

		it("ignores nested keys", function()
			local result = skills.parse_frontmatter("---\nname: nuxt\nmetadata:\n  name: not-this\n---\n")
			assert.equals("nuxt", result.name)
		end)

		it("stops at the closing delimiter", function()
			local result = skills.parse_frontmatter("---\nname: real\n---\n\nname: prose\n")
			assert.equals("real", result.name)
		end)

		it("returns an empty table without frontmatter", function()
			assert.same({}, skills.parse_frontmatter("# just a heading\n"))
		end)

		it("leaves description nil when absent", function()
			local result = skills.parse_frontmatter("---\nname: bare\n---\n")
			assert.is_nil(result.description)
		end)
	end)

	describe("skill_name", function()
		local skills = load_module()

		it("prefers the frontmatter name", function()
			assert.equals(
				"commit-commands:create-branch",
				skills.skill_name({ "create-branch" }, {
					name = "commit-commands:create-branch",
				})
			)
		end)

		it("joins nested path segments with a colon", function()
			assert.equals(
				"commit-commands:create-branch",
				skills.skill_name({ "commit-commands", "create-branch" }, {})
			)
		end)

		it("falls back to the directory name without frontmatter", function()
			assert.equals("grilling", skills.skill_name({ "grilling" }, nil))
		end)

		it("ignores an empty frontmatter name", function()
			assert.equals("grilling", skills.skill_name({ "grilling" }, { name = "" }))
		end)
	end)

	describe("merge", function()
		local skills = load_module()

		it("lets the project-local skill win", function()
			local merged = skills.merge(
				{ { name = "a", description = "global" } },
				{ { name = "a", description = "local" } }
			)
			assert.equals(1, #merged)
			assert.equals("local", merged[1].description)
		end)

		it("sorts by name", function()
			local merged = skills.merge({ { name = "b" }, { name = "a" } }, { { name = "c" } })
			assert.same({ "a", "b", "c" }, { merged[1].name, merged[2].name, merged[3].name })
		end)

		it("tolerates nil lists", function()
			assert.same({}, skills.merge(nil, nil))
		end)
	end)

	describe("to_items", function()
		local skills = load_module()

		it("prefixes label, filter text and insert text with a slash", function()
			local items = skills.to_items({ { name = "grilling", description = "grill me" } })
			assert.equals(1, #items)
			assert.equals("/grilling", items[1].label)
			assert.equals("/grilling", items[1].filterText)
			assert.equals("/grilling", items[1].insertText)
			assert.equals("grill me", items[1].documentation)
		end)

		it("returns nothing for an empty list", function()
			assert.same({}, skills.to_items({}))
		end)
	end)

	describe("read_skill", function()
		local skills = load_module()

		it("reads name and description from SKILL.md", function()
			local dir = make_skill_dir("---\nname: from-frontmatter\ndescription: desc\n---\n")
			local skill = skills.read_skill(dir, { "dir-name" })
			os.execute("rm -rf " .. dir)

			assert.equals("from-frontmatter", skill.name)
			assert.equals("desc", skill.description)
		end)

		it("returns nil when the directory holds no SKILL.md", function()
			local dir = make_skill_dir("")
			os.remove(dir .. "/SKILL.md")
			local skill = skills.read_skill(dir, { "dir-name" })
			os.execute("rm -rf " .. dir)

			assert.is_nil(skill)
		end)
	end)

	describe("cache_key", function()
		local saved_vim
		local stats

		before_each(function()
			saved_vim = _G.vim
			stats = {}
			_G.vim = {
				loop = {
					fs_stat = function(path)
						return stats[path]
					end,
					fs_scandir = function()
						return nil
					end,
				},
			}
		end)

		after_each(function()
			_G.vim = saved_vim
		end)

		it("changes when a root mtime moves by nanoseconds", function()
			local skills = load_module()
			stats["/root"] = { mtime = { sec = 100, nsec = 1 } }
			local first = skills.cache_key({ "/root" })
			stats["/root"] = { mtime = { sec = 100, nsec = 2 } }
			assert.are_not.equals(first, skills.cache_key({ "/root" }))
		end)

		it("is stable while nothing changes", function()
			local skills = load_module()
			stats["/root"] = { mtime = { sec = 100, nsec = 1 } }
			assert.equals(skills.cache_key({ "/root" }), skills.cache_key({ "/root" }))
		end)

		it("tolerates a missing root", function()
			local skills = load_module()
			assert.equals("/gone@0.0", skills.cache_key({ "/gone" }))
		end)
	end)

	describe("cache_key on a real filesystem", function()
		local saved_vim
		local root

		before_each(function()
			saved_vim = _G.vim
			_G.vim = { loop = real_loop() }
			root = make_dir()
		end)

		after_each(function()
			_G.vim = saved_vim
			os.execute("rm -rf " .. root)
		end)

		it("is stable while nothing changes", function()
			local skills = load_module()
			os.execute("mkdir -p " .. root .. "/alpha")
			write_file(root .. "/alpha/SKILL.md", "---\nname: alpha\n---\n")
			assert.equals(skills.cache_key({ root }), skills.cache_key({ root }))
		end)

		it("changes when SKILL.md appears in an existing directory", function()
			local skills = load_module()
			os.execute("mkdir -p " .. root .. "/alpha")
			local before = skills.cache_key({ root })

			write_file(root .. "/alpha/SKILL.md", "---\nname: alpha\n---\n")
			assert.are_not.equals(before, skills.cache_key({ root }))
		end)

		it("changes when SKILL.md appears in an existing nested directory", function()
			local skills = load_module()
			os.execute("mkdir -p " .. root .. "/plugin/nested")
			local before = skills.cache_key({ root })

			write_file(root .. "/plugin/nested/SKILL.md", "---\nname: nested\n---\n")
			assert.are_not.equals(before, skills.cache_key({ root }))
		end)

		it("changes when a skill is removed", function()
			local skills = load_module()
			os.execute("mkdir -p " .. root .. "/alpha")
			write_file(root .. "/alpha/SKILL.md", "---\nname: alpha\n---\n")
			local before = skills.cache_key({ root })

			os.remove(root .. "/alpha/SKILL.md")
			assert.are_not.equals(before, skills.cache_key({ root }))
		end)
	end)

	describe("discover", function()
		local saved_vim

		before_each(function()
			saved_vim = _G.vim
			_G.vim = {}
		end)

		after_each(function()
			_G.vim = saved_vim
		end)

		--- Stub the roots/scan/cache_key seam so discover's caching is the only
		--- thing under test, and count how often a rescan happens.
		local function stub(skills, key)
			local scans = { count = 0 }
			skills.roots = function()
				return { "/root" }
			end
			skills.cache_key = function()
				return key()
			end
			skills.scan = function()
				scans.count = scans.count + 1
				return { { name = "grilling" } }
			end
			return scans
		end

		it("reuses the cache while the key is unchanged", function()
			local skills = load_module()
			local scans = stub(skills, function()
				return "same"
			end)

			skills.discover()
			skills.discover()
			assert.equals(1, scans.count)
		end)

		it("rescans once the key changes", function()
			local skills = load_module()
			local key = "first"
			local scans = stub(skills, function()
				return key
			end)

			skills.discover()
			key = "second"
			skills.discover()
			assert.equals(2, scans.count)
		end)
	end)

	describe("discover on a real filesystem", function()
		local saved_vim
		local root

		before_each(function()
			saved_vim = _G.vim
			_G.vim = { loop = real_loop() }
			root = make_dir()
		end)

		after_each(function()
			_G.vim = saved_vim
			os.execute("rm -rf " .. root)
		end)

		local function names(skills)
			local found = {}
			for _, skill in ipairs(skills) do
				table.insert(found, skill.name)
			end
			return found
		end

		--- Point the module at the temporary root only, leaving discovery itself
		--- (scan, cache key, cache) untouched.
		local function load_rooted()
			local skills = load_module()
			skills.roots = function()
				return { root }
			end
			return skills
		end

		it("sees a skill added to a directory that already existed", function()
			local skills = load_rooted()
			os.execute("mkdir -p " .. root .. "/alpha " .. root .. "/beta")
			write_file(root .. "/alpha/SKILL.md", "---\nname: alpha\n---\n")
			assert.same({ "alpha" }, names(skills.discover()))

			write_file(root .. "/beta/SKILL.md", "---\nname: beta\n---\n")
			assert.same({ "alpha", "beta" }, names(skills.discover()))
		end)

		it("sees a skill added below a plugin directory that already existed", function()
			local skills = load_rooted()
			os.execute("mkdir -p " .. root .. "/plugin/nested")
			assert.same({}, names(skills.discover()))

			write_file(root .. "/plugin/nested/SKILL.md", "---\nname: plugin:nested\n---\n")
			assert.same({ "plugin:nested" }, names(skills.discover()))
		end)

		it("sees a skill removed", function()
			local skills = load_rooted()
			os.execute("mkdir -p " .. root .. "/alpha")
			write_file(root .. "/alpha/SKILL.md", "---\nname: alpha\n---\n")
			assert.same({ "alpha" }, names(skills.discover()))

			os.execute("rm -rf " .. root .. "/alpha")
			assert.same({}, names(skills.discover()))
		end)

		it("sees a nested skill removed", function()
			local skills = load_rooted()
			os.execute("mkdir -p " .. root .. "/plugin/nested")
			write_file(root .. "/plugin/nested/SKILL.md", "---\nname: plugin:nested\n---\n")
			assert.same({ "plugin:nested" }, names(skills.discover()))

			os.remove(root .. "/plugin/nested/SKILL.md")
			assert.same({}, names(skills.discover()))
		end)

		it("sees a description edited inside an existing skill", function()
			local skills = load_rooted()
			os.execute("mkdir -p " .. root .. "/alpha")
			write_file(root .. "/alpha/SKILL.md", "---\nname: alpha\ndescription: first\n---\n")
			assert.equals("first", skills.discover()[1].description)

			write_file(root .. "/alpha/SKILL.md", "---\nname: alpha\ndescription: second\n---\n")
			-- Neovim's fs_stat reports nanoseconds, so a rewrite always moves the
			-- mtime; lfs rounds to whole seconds, hence the explicit bump here.
			require("lfs").touch(root .. "/alpha/SKILL.md", os.time() + 1)
			assert.equals("second", skills.discover()[1].description)
		end)
	end)

	describe("blink.cmp provider", function()
		local saved_vim

		before_each(function()
			saved_vim = _G.vim
			_G.vim = { bo = { filetype = "org" } }
		end)

		after_each(function()
			_G.vim = saved_vim
		end)

		it("exposes the slash trigger character", function()
			local source = load_module().new()
			assert.same({ "/" }, source:get_trigger_characters())
		end)

		it("is enabled in org and markdown buffers only", function()
			local source = load_module().new()
			_G.vim.bo.filetype = "org"
			assert.is_true(source:enabled())
			_G.vim.bo.filetype = "markdown"
			assert.is_true(source:enabled())
			_G.vim.bo.filetype = "lua"
			assert.is_false(source:enabled())
		end)

		it("completes the discovered skills", function()
			local module = load_module()
			module.discover = function()
				return { { name = "grilling", description = "grill me" } }
			end

			local result
			module.new():get_completions({ line = "/", cursor = { 1, 1 } }, function(res)
				result = res
			end)

			assert.equals(1, #result.items)
			assert.equals("/grilling", result.items[1].label)
			assert.is_false(result.is_incomplete_backward)
			assert.is_false(result.is_incomplete_forward)
		end)
	end)
end)
