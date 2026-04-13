-- plugins/orgmode/actions.lua
-- Action functions for orgmode keymaps. All non-trivial logic lives here.

local M = {}

--- Get a property value from the closest org heading.
local function get_heading_property(name)
	local orgmode = require("orgmode")
	local closest = orgmode.files:get_closest_headline()
	if not closest then
		return nil
	end
	return closest:get_property(name)
end

--- Resolve the :DIR: property to an expanded path; returns nil with a notify on failure.
local function resolve_dir()
	local dir = get_heading_property("DIR")
	if not dir or vim.trim(dir) == "" then
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

--- Validate tmux availability; returns true if usable.
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

--- Close all panes except the current one (keep max 2 panes).
local function close_other_panes()
	local count = tonumber(vim.fn.system("tmux list-panes | wc -l"))
	if count and count >= 2 then
		vim.fn.system({ "tmux", "kill-pane", "-a" })
	end
end

--- Open a tmux split pane with the given command args.
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

--- Open nvim in the left tmux pane at the heading's :DIR:.
function M.open_nvim_pane()
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

--- Resume a Claude session in the right tmux pane using :SESSION_ID:.
function M.resume_claude_session()
	local dir = resolve_dir()
	if not dir then
		return
	end
	local session_id = get_heading_property("SESSION_ID")
	if not session_id or vim.trim(session_id) == "" then
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

--- Send the current visual selection to Claude Code in the right tmux pane.
function M.send_prompt_to_claude()
	if not check_tmux() then
		return
	end
	local srow, scol = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local erow, ecol = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	if srow == 0 or erow == 0 then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end
	if (srow > erow) or (srow == erow and scol > ecol) then
		srow, erow = erow, srow
		scol, ecol = ecol, scol
	end
	local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol, erow - 1, ecol + 1, {})
	local text = table.concat(lines, "\n")
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

--- Open a terminal in the left tmux pane at the heading's :DIR:.
function M.open_terminal_pane()
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

return M
