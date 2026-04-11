local M = {}

--- Get a property value from the current org heading
local function get_heading_property(name)
	local orgmode = require("orgmode")
	local closest = orgmode.files:get_closest_headline()
	if not closest then
		return nil
	end
	return closest:get_property(name)
end

--- Resolve :DIR: property to an expanded path, returns nil on failure
local function resolve_dir()
	local dir = get_heading_property("DIR")
	if not dir then
		vim.notify("No :DIR: property found in current heading", vim.log.levels.WARN)
		return nil
	end
	local expanded = vim.fn.expand(dir)
	if vim.fn.isdirectory(expanded) == 0 then
		vim.notify("Directory does not exist: " .. expanded, vim.log.levels.ERROR)
		return nil
	end
	return expanded
end

--- Validate tmux availability; returns true if usable
local function check_tmux()
	if vim.fn.executable("tmux") ~= 1 then
		vim.notify("tmux is not installed", vim.log.levels.ERROR)
		return false
	end
	if not vim.env.TMUX then
		vim.notify("Not inside a tmux session", vim.log.levels.ERROR)
		return false
	end
	return true
end

--- Close all panes except the current one (keep max 2 panes)
local function close_other_panes()
	local count = tonumber(vim.fn.system("tmux list-panes | wc -l"))
	if count and count >= 2 then
		vim.fn.system({ "tmux", "kill-pane", "-a" })
	end
end

--- Open a tmux split pane with the given command args
local function open_tmux_pane(split_args, success_msg, error_msg)
	if not check_tmux() then
		return
	end
	close_other_panes()
	vim.fn.system(split_args)
	if vim.v.shell_error ~= 0 then
		vim.notify(error_msg, vim.log.levels.ERROR)
		return
	end
	vim.notify(success_msg, vim.log.levels.INFO)
end

--- Open nvim in left tmux pane at :DIR:
local function open_nvim_pane()
	local dir = resolve_dir()
	if not dir then
		return
	end
	open_tmux_pane(
		{ "tmux", "split-window", "-hb", "-c", dir, "nvim" },
		"Opened nvim in left pane: " .. dir,
		"Failed to open tmux pane at: " .. dir
	)
end

--- Resume Claude session in right tmux pane from :SESSION_ID:
local function resume_claude_session()
	local dir = resolve_dir()
	if not dir then
		return
	end
	local session_id = get_heading_property("SESSION_ID")
	if not session_id then
		vim.notify("No :SESSION_ID: property found in current heading", vim.log.levels.WARN)
		return
	end
	if vim.fn.executable("claude") ~= 1 then
		vim.notify("claude is not installed", vim.log.levels.ERROR)
		return
	end
	open_tmux_pane(
		{ "tmux", "split-window", "-h", "-c", dir, "claude", "--resume", session_id },
		"Resumed Claude session in right pane: " .. session_id,
		"Failed to resume Claude session: " .. session_id
	)
end

--- Send visual selection to Claude Code in right tmux pane
local function send_prompt_to_claude()
	if not check_tmux() then
		return
	end
	vim.cmd('normal! "vy')
	local text = vim.fn.getreg("v")
	if not text or text == "" then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end
	vim.fn.system({ "tmux", "send-keys", "-t", "{right}", text, "Enter" })
	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to send prompt to right pane", vim.log.levels.ERROR)
		return
	end
	vim.notify("Sent prompt to Claude Code", vim.log.levels.INFO)
end

--- Open terminal in left tmux pane at :DIR:
local function open_terminal_pane()
	local dir = resolve_dir()
	if not dir then
		return
	end
	open_tmux_pane(
		{ "tmux", "split-window", "-hb", "-c", dir },
		"Opened terminal in left pane: " .. dir,
		"Failed to open terminal at: " .. dir
	)
end

function M.setup()
	local org_dir = "~/ghq/github.com/mikinovation/org"
	vim.keymap.set("n", "<leader>or", "<cmd>edit " .. org_dir .. "/refile.org<CR>", { desc = "Open refile.org" })
	vim.keymap.set("n", "<leader>ov", open_nvim_pane, { desc = "Open nvim in left tmux pane at :DIR:" })
	vim.keymap.set("n", "<leader>oC", resume_claude_session, { desc = "Resume Claude session in right tmux pane" })
	vim.keymap.set("v", "<leader>op", send_prompt_to_claude, { desc = "Send selection to Claude Code" })
	vim.keymap.set("n", "<leader>oT", open_terminal_pane, { desc = "Open terminal in left tmux pane at :DIR:" })
end

return M
