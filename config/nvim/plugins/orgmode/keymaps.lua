local M = {}

local ORG_DIR = "~/ghq/github.com/mikinovation/org"

function M.setup()
	local actions = require("plugins.orgmode.actions")
	local map = vim.keymap.set

	map("n", "<leader>or", "<cmd>edit " .. ORG_DIR .. "/refile.org<CR>", { desc = "Open refile.org" })

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "org",
		callback = function(ev)
			local function bopts(desc)
				return { buffer = ev.buf, desc = desc }
			end
			map("n", "<leader>ov", actions.open_nvim_pane, bopts("Open nvim in left tmux pane at :DIR:"))
			map("n", "<leader>oC", actions.resume_claude_session, bopts("Resume Claude session in right tmux pane"))
			map("v", "<leader>op", actions.send_prompt_to_claude, bopts("Send selection to Claude Code"))
			map("v", "<leader>om", actions.copy_as_markdown, bopts("Copy selection as Markdown (via pandoc)"))
			map("n", "<leader>oT", actions.open_terminal_pane, bopts("Open terminal in left tmux pane at :DIR:"))
		end,
	})
end

return M
