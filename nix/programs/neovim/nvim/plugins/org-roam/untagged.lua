-- plugins/org-roam/untagged.lua
-- Finds org-roam notes that carry no OKF tag, i.e. notes whose embedded
-- YAML block (see plugins.org-roam.init template "d") has no `tags:` block
-- at all, or an empty `tags: []`.

local M = {}

--- Parse the `tags:` list out of a note's embedded YAML block.
--- Returns nil when the note has no YAML block (predates the template, or
--- was hand-written), or a list of tag strings (possibly empty) otherwise.
---@param content string
---@return string[]|nil
function M.parse_tags(content)
	local yaml_block = content:match("#%+begin_src yaml%s*\n(.-)#%+end_src")
	if not yaml_block then
		return nil
	end

	local tags_line = yaml_block:match("tags:%s*%[(.-)%]")
	if not tags_line then
		return nil
	end

	local tags = {}
	for tag in tags_line:gmatch("[^,%s]+") do
		table.insert(tags, tag)
	end
	return tags
end

--- Whether a note has no tags at all: no YAML block, or an empty tags list.
---@param content string
---@return boolean
function M.is_untagged(content)
	local tags = M.parse_tags(content)
	return tags == nil or #tags == 0
end

--- Extract the `#+TITLE:` value from note content.
---@param content string
---@return string|nil
function M.extract_title(content)
	return content:match("#%+TITLE:%s*([^\n]-)%s*\n") or content:match("#%+TITLE:%s*([^\n]-)%s*$")
end

--- Scan `directory` for untagged org-roam notes.
---@param directory string
---@return table[] entries `{ path = string, title = string }`, sorted by path
function M.find_untagged(directory)
	local dir = vim.fn.expand(directory)
	local paths = vim.fn.globpath(dir, "**/*.org", false, true)
	table.sort(paths)

	local entries = {}
	for _, path in ipairs(paths) do
		local file = io.open(path, "r")
		if file then
			local content = file:read("*a")
			file:close()
			if M.is_untagged(content) then
				table.insert(entries, {
					path = path,
					title = M.extract_title(content) or vim.fn.fnamemodify(path, ":t"),
				})
			end
		end
	end
	return entries
end

--- Open a Telescope picker listing untagged org-roam notes under `directory`.
---@param directory string
function M.picker(directory)
	local entries = M.find_untagged(directory)
	if #entries == 0 then
		vim.notify("No untagged roam notes found", vim.log.levels.INFO)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "Untagged Roam Notes",
			finder = finders.new_table({
				results = entries,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.title,
						ordinal = entry.title,
						path = entry.path,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, _map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						vim.cmd("edit " .. vim.fn.fnameescape(selection.value.path))
					end
				end)
				return true
			end,
		})
		:find()
end

return M
