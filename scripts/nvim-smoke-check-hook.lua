-- Hook vim.notify before init.lua loads to capture errors/warnings.
-- Populates _G._smoke_errors / _G._smoke_warnings (read by nvim-smoke-check-result.lua).
_G._smoke_errors = {}
_G._smoke_warnings = {}

local orig_notify = vim.notify
vim.notify = function(msg, level, opts)
	if level == vim.log.levels.ERROR then
		table.insert(_G._smoke_errors, tostring(msg))
	elseif level == vim.log.levels.WARN then
		table.insert(_G._smoke_warnings, tostring(msg))
	end
	return orig_notify(msg, level, opts)
end
