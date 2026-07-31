local M = {}

function M.setup()
	local map = vim.keymap.set

	-- Yank through yanky so the cursor stays where it was.
	-- The ring itself is filled by TextYankPost, so plain y would work too.
	map({ "n", "x" }, "y", "<Plug>(YankyYank)", { desc = "Yank" })

	-- Put through yanky. This is required for cycling: yanky only arms the ring
	-- state from its own put mappings, so <C-p> after a plain p does nothing.
	map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Put after" })
	map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Put before" })
	map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { desc = "Put after and leave cursor at the end" })
	map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { desc = "Put before and leave cursor at the end" })

	-- Walk the yank history in place, right after a put. The ring is ordered
	-- newest first, so "next" moves further back in time: after p pasted the
	-- most recent yank, <C-n> is the one that reaches older entries.
	map("n", "<C-p>", "<Plug>(YankyPreviousEntry)", { desc = "Cycle to newer yank" })
	map("n", "<C-n>", "<Plug>(YankyNextEntry)", { desc = "Cycle to older yank" })

	-- Fuzzy pick from the whole history. <leader>p is not used because pathtool
	-- owns it as a prefix (<leader>pa, <leader>pp, ...).
	map("n", "<leader>P", "<cmd>Telescope yank_history<CR>", { desc = "[P]aste from yank history" })
end

return M
