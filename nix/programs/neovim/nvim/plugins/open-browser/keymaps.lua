local M = {}

function M.setup()
	vim.keymap.set("n", "gx", "<Plug>(openbrowser-smart-search)", { desc = "Open URL under cursor" })
	vim.keymap.set("v", "gx", "<Plug>(openbrowser-smart-search)", { desc = "Open selected URL" })
end

return M
