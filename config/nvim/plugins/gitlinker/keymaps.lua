local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>gy", function()
		require("gitlinker").get_buf_range_url("n")
	end, { desc = "Copy git link to clipboard" })
end

return M
