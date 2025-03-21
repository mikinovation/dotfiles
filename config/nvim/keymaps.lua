local keymap = vim.keymap.set

-- keymap(mode, lhs, rhs, opts?)("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")
keymap("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Open diagnostics in loclist" })
keymap("n", "<leader>df", vim.diagnostic.open_float, { desc = "Open diagnostics in float" })
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
keymap("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
keymap("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
keymap("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
keymap("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

keymap("n", "<leader>rm", ":%s/\r//g<CR>", { desc = "Remove ^M" })

-- jjでノーマルモードに戻る
keymap("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Toggleterm
-- ターミナルを開く
keymap("n", "<leader>tt", ":ToggleTerm<CR>", { desc = "Toggle terminal" })

-- Neotest
keymap("n", "<leader>tn", ":lua require('neotest').run.run({strategy = 'dap'})<CR>", { desc = "Run test nearest" })
keymap("n", "<leader>tf", ":lua require('neotest').run.run(vim.fn.expand('%'))<CR>", { desc = "Run test file" })

-- Copilot Chat
vim.keymap.set("n", "<leader>cco", ":CopilotChatToggle<CR>", { desc = "[C]opilot [C]hat [T]oggle" })
vim.keymap.set("n", "<leader>ccr", ":CopilotChatReview<CR>", { desc = "[C]opilot [C]hat [R]eview" })
vim.keymap.set("n", "<leader>ccf", ":CopilotChatFix<CR>", { desc = "[C]opilot [C]hat [F]ix" })
vim.keymap.set("n", "<leader>ccd", ":CopilotChatDoc<CR>", { desc = "[C]opilot [C]hat [D]oc" })
vim.keymap.set("n", "<leader>cct", ":CopilotChatTest<CR>", { desc = "[C]opilot [C]hat [T]est" })

-- Vim-Argwrap
vim.keymap.set("n", "<leader>a", ":ArgWrap<CR>", { desc = "Argwrap" })

-- Markdown Preview
vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "[M]arkdown [P]review" })

-- Neotree
vim.keymap.set("n", "<leader>ec", ":Neotree reveal<CR>", { desc = "Reveal current file in tree" })

vim.api.nvim_set_keymap("n", "<leader>st", ":lua SendToTerminal()<CR>", { noremap = true, silent = true })

function SendToTerminal()
	local cmd = vim.fn.getline(".")
	local job_id = nil

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buftype == "terminal" then
			job_id = vim.b[buf].terminal_job_id
			break
		end
	end

	if job_id then
		vim.api.nvim_chan_send(job_id, cmd .. "\n")
	else
		print("No active terminal found!")
	end
end
