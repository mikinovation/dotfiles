local M = {}

function M.setup()
	local actions = require("plugins.neotest.actions")
	local map = vim.keymap.set

	map("n", "<leader>tn", actions.run_nearest, { desc = "Run test nearest" })
	map("n", "<leader>tD", actions.debug_nearest, { desc = "Debug test nearest (DAP)" })
	map("n", "<leader>tf", actions.run_file, { desc = "Run test file" })
end

return M
