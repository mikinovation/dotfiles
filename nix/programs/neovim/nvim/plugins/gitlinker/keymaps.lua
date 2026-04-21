local M = {}

function M.setup()
	local actions = require("plugins.gitlinker.actions")
	vim.keymap.set("n", "<leader>gy", actions.copy_git_link, { desc = "Copy git link to clipboard" })
end

return M
