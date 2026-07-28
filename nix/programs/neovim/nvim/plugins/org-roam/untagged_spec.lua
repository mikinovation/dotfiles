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
	package.loaded["plugins.org-roam.untagged"] = nil
	return dofile(module_dir .. "untagged.lua")
end

local function note(id, title, body)
	return table.concat({
		":PROPERTIES:",
		":ID: " .. id,
		":END:",
		"#+TITLE: " .. title,
		"",
		body,
	}, "\n")
end

describe("plugins.org-roam.untagged", function()
	describe("parse_tags", function()
		it("returns nil when there is no YAML block", function()
			local untagged = load_module()
			assert.is_nil(untagged.parse_tags(note("1", "No Yaml", "- some content")))
		end)

		it("returns an empty list for an empty tags array", function()
			local untagged = load_module()
			local content = note("1", "Empty Tags", "#+begin_src yaml\ntags: []\n#+end_src")
			assert.same({}, untagged.parse_tags(content))
		end)

		it("returns the parsed tags for a single tag", function()
			local untagged = load_module()
			local content = note("1", "Single Tag", "#+begin_src yaml\ntags: [issue]\n#+end_src")
			assert.same({ "issue" }, untagged.parse_tags(content))
		end)

		it("returns the parsed tags for multiple tags", function()
			local untagged = load_module()
			local content = note("1", "Multi Tag", "#+begin_src yaml\ntags: [issue, decision]\n#+end_src")
			assert.same({ "issue", "decision" }, untagged.parse_tags(content))
		end)
	end)

	describe("is_untagged", function()
		it("is true when there is no YAML block", function()
			local untagged = load_module()
			assert.is_true(untagged.is_untagged(note("1", "No Yaml", "- some content")))
		end)

		it("is true when the tags array is empty", function()
			local untagged = load_module()
			local content = note("1", "Empty Tags", "#+begin_src yaml\ntags: []\n#+end_src")
			assert.is_true(untagged.is_untagged(content))
		end)

		it("is false when the tags array has entries", function()
			local untagged = load_module()
			local content = note("1", "Tagged", "#+begin_src yaml\ntags: [issue]\n#+end_src")
			assert.is_false(untagged.is_untagged(content))
		end)
	end)

	describe("extract_title", function()
		it("extracts the title on its own line", function()
			local untagged = load_module()
			assert.equals("My Note", untagged.extract_title(note("1", "My Note", "- body")))
		end)

		it("extracts the title when it is the last line", function()
			local untagged = load_module()
			assert.equals("My Note", untagged.extract_title("#+TITLE: My Note"))
		end)
	end)

	describe("find_untagged", function()
		local saved_vim
		local tmpdir

		before_each(function()
			saved_vim = _G.vim
			tmpdir = os.tmpname()
			os.remove(tmpdir)
			os.execute(("mkdir -p '%s'"):format(tmpdir))
		end)

		after_each(function()
			os.execute(("rm -rf '%s'"):format(tmpdir))
			_G.vim = saved_vim
		end)

		local function write_file(name, content)
			local path = tmpdir .. "/" .. name
			local file = io.open(path, "w")
			file:write(content)
			file:close()
			return path
		end

		local function stub_vim(paths)
			_G.vim = {
				fn = {
					expand = function(path)
						return path
					end,
					globpath = function(_, _, _, as_list)
						if as_list then
							return paths
						end
						return table.concat(paths, "\n")
					end,
					fnamemodify = function(path, modifier)
						if modifier == ":t" then
							return path:match("([^/]+)$")
						end
						return path
					end,
				},
			}
		end

		it("returns only notes without tags, keyed by title", function()
			local tagged_path =
				write_file("tagged.org", note("1", "Tagged Note", "#+begin_src yaml\ntags: [issue]\n#+end_src"))
			local empty_tags_path =
				write_file("empty.org", note("2", "Empty Tags Note", "#+begin_src yaml\ntags: []\n#+end_src"))
			local no_yaml_path = write_file("no_yaml.org", note("3", "No Yaml Note", "- content"))

			stub_vim({ tagged_path, empty_tags_path, no_yaml_path })
			local untagged = load_module()
			local entries = untagged.find_untagged(tmpdir)

			local titles = {}
			for _, entry in ipairs(entries) do
				table.insert(titles, entry.title)
			end
			table.sort(titles)
			assert.same({ "Empty Tags Note", "No Yaml Note" }, titles)
		end)

		it("falls back to the filename when there is no title", function()
			local path = write_file("untitled.org", "- content")
			stub_vim({ path })
			local untagged = load_module()
			local entries = untagged.find_untagged(tmpdir)
			assert.equals(1, #entries)
			assert.equals("untitled.org", entries[1].title)
		end)
	end)
end)
