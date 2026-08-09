local M = {}

function M.setup()
	local actions = require("plugins.orgmode.actions")
	local ORG_DIR = require("plugins.orgmode.workflow").ORG_DIR
	local map = vim.keymap.set

	map("n", "<leader>or", "<cmd>edit " .. ORG_DIR .. "/refile.org<CR>", { desc = "Open refile.org" })

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "org",
		callback = function(ev)
			local function bopts(desc)
				return { buffer = ev.buf, desc = desc }
			end
			map("n", "cit", actions.pick_todo_state, bopts("Pick TODO state for closest heading"))
			map("n", "<leader>oxi", actions.id_get_or_create, bopts("Insert :ID: on closest heading"))
			map("v", "<leader>om", actions.copy_as_markdown, bopts("Copy selection as Markdown (via pandoc)"))
		end,
	})
end

return M
