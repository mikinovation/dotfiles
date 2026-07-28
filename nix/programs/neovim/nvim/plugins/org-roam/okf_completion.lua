-- plugins/org-roam/okf_completion.lua
-- Lightweight blink.cmp source that completes OKF `type:` values inside the
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

M.__index = M

function M.new()
	return setmetatable({}, M)
end

function M.enabled(_)
	return vim.bo.filetype == "org"
end

function M.get_trigger_characters(_)
	return { ":" }
end

function M.get_completions(_, context, callback)
	local cursor_before_line = context.line:sub(1, context.cursor[2])
	if not M.is_type_line(cursor_before_line) then
		callback({ items = {}, is_incomplete_backward = false, is_incomplete_forward = false })
		return
	end
	callback({
		items = M.complete_items(),
		is_incomplete_backward = false,
		is_incomplete_forward = false,
	})
end

return M
