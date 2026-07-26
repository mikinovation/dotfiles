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
			map("n", "<leader>oxi", actions.id_get_or_create, bopts("Insert :ID: on closest heading"))
			map("v", "<leader>om", actions.copy_as_markdown, bopts("Copy selection as Markdown (via pandoc)"))
		end,
	})
end

return M
