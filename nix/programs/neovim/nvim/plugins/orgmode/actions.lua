-- plugins/orgmode/actions.lua
-- Action functions for orgmode keymaps. All non-trivial logic lives here.

local M = {}

--- Copy the current visual selection as Markdown (converted from org via pandoc).
function M.copy_as_markdown()
	if vim.fn.executable("pandoc") ~= 1 then
		vim.notify("pandoc is not installed", vim.log.levels.ERROR)
		return
	end
	local srow, scol = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local erow, ecol = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	if srow == 0 or erow == 0 then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end
	if (srow > erow) or (srow == erow and scol > ecol) then
		srow, erow = erow, srow
		scol, ecol = ecol, scol
	end
	local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol, erow - 1, ecol + 1, {})
	local text = table.concat(lines, "\n")
	if not text or text == "" then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end
	local result = vim.fn.system({ "pandoc", "-f", "org", "-t", "markdown" }, text)
	if vim.v.shell_error ~= 0 then
		vim.notify("pandoc conversion failed", vim.log.levels.ERROR)
		return
	end
	vim.fn.setreg("+", result)
	vim.notify("Copied as Markdown", vim.log.levels.INFO)
end

--- Insert/ensure an :ID: property on the closest org heading.
function M.id_get_or_create()
	local headline = require("orgmode.api").current():get_closest_headline()
	if not headline then
		vim.notify("No heading at cursor", vim.log.levels.WARN)
		return
	end
	headline:id_get_or_create()
end

--- Rewrite an org heading line to carry `keyword` as its TODO state.
--- Passing nil for `keyword` strips the state instead. Non-heading lines are
--- returned untouched. Only words listed in plugins.orgmode.workflow count as
--- an existing state, so a heading whose text merely starts with an uppercase
--- word is not mistaken for one.
---@param line string
---@param keyword string|nil
---@return string
function M.replace_todo_keyword(line, keyword)
	local workflow = require("plugins.orgmode.workflow")
	local stars, rest = line:match("^(%*+%s+)(.*)$")
	if not stars then
		return line
	end

	local first = rest:match("^(%S+)")
	if first and workflow.keyword_set[first] then
		rest = rest:sub(#first + 1):gsub("^%s+", "")
	end

	if not keyword then
		return stars .. rest
	end
	if rest == "" then
		return stars .. keyword
	end
	return stars .. keyword .. " " .. rest
end

--- Pick a TODO state for the closest org heading from a filterable list.
--- Replaces orgmode's own `cit`, which cycles through all states one key press
--- at a time; with 11 of them that is unusable, and their fast access letters
--- are not worth memorizing.
function M.pick_todo_state()
	local workflow = require("plugins.orgmode.workflow")
	local headline = require("orgmode.api").current():get_closest_headline()
	if not headline then
		vim.notify("No heading at cursor", vim.log.levels.WARN)
		return
	end

	local line_nr = headline.position.start_line
	local choices = { "" }
	for _, keyword in ipairs(workflow.keywords()) do
		table.insert(choices, keyword)
	end

	vim.ui.select(choices, {
		prompt = "Org Todo State",
		format_item = function(keyword)
			if keyword == "" then
				return "(none)"
			end
			return string.format("%-10s %s", keyword, workflow.labels[keyword] or "")
		end,
	}, function(choice)
		if choice == nil then
			return
		end
		local line = vim.api.nvim_buf_get_lines(0, line_nr - 1, line_nr, false)[1]
		if not line then
			return
		end
		local updated = M.replace_todo_keyword(line, choice ~= "" and choice or nil)
		vim.api.nvim_buf_set_lines(0, line_nr - 1, line_nr, false, { updated })
	end)
end

return M
