local M = {}

function M.setup()
	local org_dir = "~/ghq/github.com/mikinovation/org"
	vim.keymap.set("n", "<leader>or", "<cmd>edit " .. org_dir .. "/refile.org<CR>", { desc = "Open refile.org" })
end

return M
