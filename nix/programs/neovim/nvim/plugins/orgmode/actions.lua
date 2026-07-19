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

return M
