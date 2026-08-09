-- luacheck: globals describe it assert

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

local workflow = dofile(spec_dir() .. "workflow.lua")

--- Set of every keyword in the sequence, with the `"|"` separator dropped.
local function keyword_set()
	local set = {}
	for _, keyword in ipairs(workflow.todo_keywords) do
		if keyword ~= "|" then
			set[keyword] = true
		end
	end
	return set
end

--- Keys present in `a` but missing from `b`.
local function missing_from(a, b)
	local result = {}
	for key in pairs(a) do
		if not b[key] then
			table.insert(result, key)
		end
	end
	table.sort(result)
	return result
end

describe("plugins.orgmode.workflow", function()
	describe("todo_keywords", function()
		it("has exactly one done separator", function()
			local separators = 0
			for _, keyword in ipairs(workflow.todo_keywords) do
				if keyword == "|" then
					separators = separators + 1
				end
			end
			assert.equals(1, separators)
		end)

		it("carries no fast access keys", function()
			-- The picker in plugins.orgmode.actions replaces them; leaving `(x)`
			-- suffixes in would make orgmode open its own single-key popup instead.
			for _, keyword in ipairs(workflow.todo_keywords) do
				assert.is_nil(keyword:match("%(.%)$"))
			end
		end)

		it("finishes on DONE alone, the keyword existing headlines already use", function()
			local separator_index
			for index, keyword in ipairs(workflow.todo_keywords) do
				if keyword == "|" then
					separator_index = index
				end
			end
			local done_side = {}
			for index = separator_index + 1, #workflow.todo_keywords do
				table.insert(done_side, workflow.todo_keywords[index])
			end
			assert.same({ "DONE" }, done_side)
		end)
	end)

	describe("keywords", function()
		it("returns the sequence without the separator", function()
			local keywords = workflow.keywords()
			assert.equals(#workflow.todo_keywords - 1, #keywords)
			for _, keyword in ipairs(keywords) do
				assert.not_equals("|", keyword)
			end
		end)

		it("preserves sequence order", function()
			assert.equals("TODO", workflow.keywords()[1])
			assert.equals("DONE", workflow.keywords()[#workflow.keywords()])
		end)
	end)

	describe("keyword_set", function()
		it("matches todo_keywords", function()
			local expected = keyword_set()
			assert.same({}, missing_from(expected, workflow.keyword_set))
			assert.same({}, missing_from(workflow.keyword_set, expected))
		end)
	end)

	describe("todo_keyword_faces", function()
		-- A typo'd key here is silently ignored by orgmode, so this is the only
		-- thing that catches it.
		it("defines a face for every keyword and nothing else", function()
			local expected = keyword_set()
			assert.same({}, missing_from(expected, workflow.todo_keyword_faces))
			assert.same({}, missing_from(workflow.todo_keyword_faces, expected))
		end)
	end)

	describe("labels", function()
		it("labels every keyword and nothing else", function()
			local expected = keyword_set()
			assert.same({}, missing_from(expected, workflow.labels))
			assert.same({}, missing_from(workflow.labels, expected))
		end)
	end)

	describe("agenda_files", function()
		it("scans only paths under ORG_DIR", function()
			assert.is_true(#workflow.agenda_files > 0)
			for _, path in ipairs(workflow.agenda_files) do
				assert.equals(workflow.ORG_DIR, path:sub(1, #workflow.ORG_DIR))
			end
		end)

		it("excludes the journal directory", function()
			for _, path in ipairs(workflow.agenda_files) do
				assert.is_nil(path:match("journal"))
			end
		end)
	end)

	describe("agenda_custom_commands", function()
		it("sorts the workflow view by todo state", function()
			local view = workflow.agenda_custom_commands.w
			assert.is_table(view)
			assert.equals("todo", view.types[1].type)
			assert.same({ "todo-state-up" }, view.types[1].org_agenda_sorting_strategy)
		end)
	end)
end)
