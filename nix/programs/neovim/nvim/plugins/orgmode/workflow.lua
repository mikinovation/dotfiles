-- plugins/orgmode/workflow.lua
-- Development ticket workflow for orgmode: the TODO keyword sequence, their
-- colors, and which files the agenda scans.
--
-- Deliberately free of any vim API use so the spec can `dofile` it without a
-- Neovim runtime.

local M = {}

M.ORG_DIR = "~/ghq/github.com/mikinovation/org"

-- 未着手 → ISSUE作成 → 設計 → テストケース作成 → 実装 → セルフレビュー →
-- レビュー → QA中 → QA完了 → 受け入れ中 → 受け入れ完了
--
-- `DONE` stays on the finished side purely for the ~440 existing day-to-day
-- headlines that already use it; tickets finish at `ACCEPTED`.
--
-- No `(x)` fast access keys: `cit` is remapped to a fuzzy picker in
-- plugins.orgmode.actions, and insert-mode completion offers these values via
-- orgmode's own blink source.
M.todo_keywords = {
	"TODO",
	"ISSUE",
	"DESIGN",
	"TEST",
	"IMPL",
	"SELF",
	"REVIEW",
	"QA",
	"QADONE",
	"ACCEPTING",
	"|",
	"ACCEPTED",
	"DONE",
	"CANCELLED",
}

M.labels = {
	TODO = "未着手",
	ISSUE = "ISSUE作成",
	DESIGN = "設計",
	TEST = "テストケース作成",
	IMPL = "実装",
	SELF = "セルフレビュー",
	REVIEW = "レビュー",
	QA = "QA中",
	QADONE = "QA完了",
	ACCEPTING = "受け入れ中",
	ACCEPTED = "受け入れ完了",
	DONE = "完了",
	CANCELLED = "中止",
}

--- Keywords in sequence order, with `"|"` dropped.
---@return string[]
function M.keywords()
	local result = {}
	for _, keyword in ipairs(M.todo_keywords) do
		if keyword ~= "|" then
			table.insert(result, keyword)
		end
	end
	return result
end

--- Lookup table used to tell an existing keyword apart from ordinary headline
--- text when rewriting a heading line.
---@type table<string, boolean>
M.keyword_set = (function()
	local set = {}
	for _, keyword in ipairs(M.todo_keywords) do
		if keyword ~= "|" then
			set[keyword] = true
		end
	end
	return set
end)()

-- Colored by who holds the ball, not by which step it is: with 13 states the
-- step-by-step hue would be unreadable, and "is this on me or on someone else"
-- is the question actually asked when scanning a file.
local NOT_STARTED = ":foreground #f7768e :weight bold"
local MINE = ":foreground #e0af68 :weight bold"
local THEIRS = ":foreground #7aa2f7 :weight bold"
local FINISHED = ":foreground #9ece6a :weight bold"
local ABANDONED = ":foreground #565f89 :slant italic"

M.todo_keyword_faces = {
	TODO = NOT_STARTED,
	ISSUE = MINE,
	DESIGN = MINE,
	TEST = MINE,
	IMPL = MINE,
	SELF = MINE,
	REVIEW = THEIRS,
	QA = THEIRS,
	QADONE = THEIRS,
	ACCEPTING = THEIRS,
	ACCEPTED = FINISHED,
	DONE = FINISHED,
	CANCELLED = ABANDONED,
}

-- `journal/**` is excluded on purpose: it holds Claude session logs whose
-- headlines stay `* TODO` after the work is done, which would bury the ~30
-- headlines that are actually open.
M.agenda_files = {
	M.ORG_DIR .. "/*.org",
	M.ORG_DIR .. "/agenda/**/*.org",
	M.ORG_DIR .. "/tasks/**/*.org",
}

M.agenda_custom_commands = {
	w = {
		description = "Workflow status",
		types = {
			{
				type = "todo",
				org_agenda_overriding_header = "Workflow",
				org_agenda_sorting_strategy = { "todo-state-up" },
			},
		},
	},
}

return M
