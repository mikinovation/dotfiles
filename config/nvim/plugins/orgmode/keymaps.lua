local M = {}

--- Get the :DIR: property value from the current org heading
local function get_dir_property()
	local orgmode = require("orgmode")
	local closest = orgmode.files:get_closest_headline()
	if not closest then
		return nil
	end
	local dir = closest:get_property("DIR")
	if dir then
		return dir
	end
	return nil
end

function M.setup()
	local org_dir = "~/ghq/github.com/mikinovation/org"
	vim.keymap.set("n", "<leader>or", "<cmd>edit " .. org_dir .. "/refile.org<CR>", { desc = "Open refile.org" })
	vim.keymap.set("n", "<leader>ov", function()
		local dir = get_dir_property()
		if not dir then
			vim.notify("No :DIR: property found in current heading", vim.log.levels.WARN)
			return
		end
		local expanded = vim.fn.expand(dir)
		if vim.fn.isdirectory(expanded) == 0 then
			vim.notify("Directory does not exist: " .. expanded, vim.log.levels.ERROR)
			return
		end
		vim.fn.system({ "tmux", "split-window", "-hb", "-c", expanded, "nvim" })
		vim.notify("Opened nvim in left pane: " .. expanded)
	end, { desc = "Open nvim in left tmux pane at :DIR:" })
end

return M
