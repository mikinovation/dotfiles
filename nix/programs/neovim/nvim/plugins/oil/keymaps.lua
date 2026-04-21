local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>fo", require("oil").open, { desc = "Open parent directory" })
end

return M
