-- plugins/gitlinker/actions.lua

local M = {}

--- Copy a git-host URL for the current buffer/range to the clipboard.
function M.copy_git_link()
	require("gitlinker").get_buf_range_url("n")
end

return M
