-- plugins/orgmode/workflow.lua
-- Development ticket workflow for orgmode: the TODO keyword sequence, their
-- colors, and which files the agenda scans.
--
-- Deliberately free of any vim API use so the spec can `dofile` it without a
-- Neovim runtime.

local M = {}

M.ORG_DIR = "~/ghq/github.com/mikinovation/org"

-- 未着手 → ISSUE作成 → 設計 → テストケース作成 → 実装 → セルフレビュー →
-- レビュー → QA中 → QA完了 → 受け入れ中 → 完了
--
-- A single finished state. Accepted tickets, finished day-to-day chores and
-- abandoned work all land on `DONE`: the distinction stopped earning its
-- keyword once the ball was no longer with anyone. `DONE` is the survivor
-- rather than `ACCEPTED` because ~440 existing headlines already use it, and
-- dropping it would strip them of their keyword.
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
	"DONE",
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
	DONE = "完了",
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

-- Colored by who holds the ball, not by which step it is: with 11 states the
-- step-by-step hue would be unreadable, and "is this on me or on someone else"
-- is the question actually asked when scanning a file.
--
-- The open states are drawn as filled badges rather than colored text. Headline
-- text already spends every hue tokyonight has -- orgmode links levels 1..8 to
-- Title/Constant/Identifier/Statement/PreProc/Type/Special/String, which resolve
-- to blue/orange/magenta/magenta/cyan/blue1/blue1/green -- so a foreground-only
-- state is indistinguishable from the heading it sits in front of. A background
-- separates them at any level. The finished state stays unfilled so that only
-- what is still moving draws the eye.
local BADGE_FG = "#1a1b26"
local NOT_STARTED = ":foreground " .. BADGE_FG .. " :background #f7768e :weight bold"
local MINE = ":foreground " .. BADGE_FG .. " :background #e0af68 :weight bold"
local THEIRS = ":foreground " .. BADGE_FG .. " :background #7aa2f7 :weight bold"
local FINISHED = ":foreground #565f89"

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
	DONE = FINISHED,
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
