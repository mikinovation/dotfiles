local M = {}

function M.setup()
	vim.keymap.set("n", "<leader>tn", ":lua require('neotest').run.run()<CR>", { desc = "Run test nearest" })
	vim.keymap.set(
		"n",
		"<leader>tD",
		":lua require('neotest').run.run({strategy = 'dap'})<CR>",
		{ desc = "Debug test nearest (DAP)" }
	)
	vim.keymap.set(
		"n",
		"<leader>tf",
		":lua require('neotest').run.run(vim.fn.expand('%'))<CR>",
		{ desc = "Run test file" }
	)
end

return M
