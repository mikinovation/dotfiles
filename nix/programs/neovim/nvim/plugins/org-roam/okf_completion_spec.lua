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
	package.loaded["plugins.org-roam.okf_completion"] = nil
	return dofile(module_dir .. "okf_completion.lua")
end

describe("plugins.org-roam.okf_completion", function()
	describe("is_type_line", function()
		local okf = load_module()

		it("matches a bare type key", function()
			assert.is_true(okf.is_type_line("type: "))
		end)

		it("matches an indented type key", function()
			assert.is_true(okf.is_type_line("  type:"))
		end)

		it("matches a partially typed value", function()
			assert.is_true(okf.is_type_line("type: no"))
		end)

		it("does not match a similarly named key", function()
			assert.is_false(okf.is_type_line("types:"))
		end)

		it("does not match a key that merely ends in type:", function()
			assert.is_false(okf.is_type_line("content_type:"))
		end)

		it("does not match an unrelated key", function()
			assert.is_false(okf.is_type_line("description:"))
		end)

		it("does not match an empty line", function()
			assert.is_false(okf.is_type_line(""))
		end)
	end)

	describe("complete_items", function()
		it("returns one item per type value", function()
			local okf = load_module()
			local items = okf.complete_items()
			assert.equals(#okf.type_values, #items)

			local labels = {}
			for _, item in ipairs(items) do
				table.insert(labels, item.label)
			end
			assert.same(okf.type_values, labels)
		end)
	end)

	describe("type_values", function()
		it("exposes the expected shortlist", function()
			local okf = load_module()
			assert.same({ "note", "reference", "project", "person", "meeting", "decision" }, okf.type_values)
		end)
	end)

	describe("register", function()
		local saved_vim
		local registered_name
		local registered_source

		before_each(function()
			saved_vim = _G.vim
			registered_name = nil
			registered_source = nil
			_G.vim = { bo = { filetype = "org" } }
			package.loaded["cmp"] = {
				register_source = function(name, source)
					registered_name = name
					registered_source = source
				end,
			}
		end)

		after_each(function()
			package.loaded["cmp"] = nil
			_G.vim = saved_vim
		end)

		it("registers an okf source with cmp", function()
			load_module().register()
			assert.equals("okf", registered_name)
			assert.is_function(registered_source.complete)
		end)

		it("does nothing when cmp is not installed", function()
			package.loaded["cmp"] = nil
			assert.has_no.errors(function()
				load_module().register()
			end)
		end)

		it("is only available in org buffers", function()
			load_module().register()
			_G.vim.bo.filetype = "org"
			assert.is_true(registered_source:is_available())
			_G.vim.bo.filetype = "markdown"
			assert.is_false(registered_source:is_available())
		end)

		it("completes only when on a type: line", function()
			load_module().register()

			local result
			registered_source:complete({ context = { cursor_before_line = "type: " } }, function(res)
				result = res
			end)
			assert.equals(6, #result.items)

			registered_source:complete({ context = { cursor_before_line = "description: " } }, function(res)
				result = res
			end)
			assert.equals(0, #result.items)
		end)
	end)
end)
