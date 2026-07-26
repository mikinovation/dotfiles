-- plugins/org-roam/okf_completion.lua
-- Lightweight nvim-cmp source that completes OKF `type:` values inside the
-- YAML block org-roam captures embed. OKF itself defines no controlled
-- vocabulary for `type`; this is a personal shortlist for org-roam notes.

local M = {}

M.type_values = { "note", "reference", "project", "person", "meeting", "decision" }

M.type_docs = {
	note = "日常のメモ/永続ノート",
	reference = "外部資料の参照",
	project = "プロジェクト単位のノート",
	person = "人物に関するノート",
	meeting = "会議・商談の議事録",
	decision = "意思決定・トレードオフの記録",
}

--- Whether the text preceding the cursor is on a YAML `type:` line.
--- Anchored at the start so it doesn't match unrelated keys that merely end
--- in "type:" (e.g. "content_type:").
---@param cursor_before_line string
---@return boolean
function M.is_type_line(cursor_before_line)
	return cursor_before_line:find("^%s*type:%s*") ~= nil
end

--- Build cmp completion items for the OKF type shortlist.
---@return table[]
function M.complete_items()
	local items = {}
	for _, value in ipairs(M.type_values) do
		table.insert(items, { label = value, documentation = M.type_docs[value] })
	end
	return items
end

--- Register the "okf" completion source with nvim-cmp, if it is loaded.
function M.register()
	local ok, cmp = pcall(require, "cmp")
	if not ok then
		return
	end

	local source = {}

	function source.is_available(_)
		return vim.bo.filetype == "org"
	end

	function source.get_debug_name(_)
		return "okf"
	end

	function source.get_trigger_characters(_)
		return { ":" }
	end

	function source.complete(_, params, callback)
		if not M.is_type_line(params.context.cursor_before_line) then
			return callback({ items = {}, isIncomplete = false })
		end
		callback({ items = M.complete_items(), isIncomplete = false })
	end

	cmp.register_source("okf", source)
end

return M
