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

	describe("blink.cmp provider", function()
		local saved_vim

		before_each(function()
			saved_vim = _G.vim
			_G.vim = { bo = { filetype = "org" } }
		end)

		after_each(function()
			_G.vim = saved_vim
		end)

		it("exposes trigger characters", function()
			local source = load_module().new()
			assert.same({ ":" }, source:get_trigger_characters())
		end)

		it("is only enabled in org buffers", function()
			local source = load_module().new()
			_G.vim.bo.filetype = "org"
			assert.is_true(source:enabled())
			_G.vim.bo.filetype = "markdown"
			assert.is_false(source:enabled())
		end)

		it("completes only when on a type: line", function()
			local source = load_module().new()

			local result
			source:get_completions({ line = "type: ", cursor = { 1, 6 } }, function(res)
				result = res
			end)
			assert.equals(6, #result.items)

			source:get_completions({ line = "description: ", cursor = { 1, 13 } }, function(res)
				result = res
			end)
			assert.equals(0, #result.items)
		end)
	end)
end)
