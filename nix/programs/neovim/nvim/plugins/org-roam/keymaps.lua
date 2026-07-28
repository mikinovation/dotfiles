local M = {}

--- @param directory string org-roam notes directory to scan
function M.setup(directory)
	vim.keymap.set("n", "<leader>su", function()
		require("plugins.org-roam.untagged").picker(directory)
	end, { desc = "[S]earch [U]ntagged Roam Notes" })
end

return M
