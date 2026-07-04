-- plugins/herdr/actions.lua
-- Send text directly to a running herdr agent pane, picked by name.
-- All non-trivial logic lives here; keymaps are wired from plugins/sidekick.
--
-- herdr CLI subcommands used here all print a single JSON line on stdout:
--   {"id": "...", "result": {...}}          on success
--   {"id": "...", "error": {"code": "..."}} on failure
-- Verified against herdr 0.7.1 (`herdr agent list|get|send`, `herdr pane send-keys`).
-- `agent send` types literal text but does NOT submit it; submitting requires
-- pressing Enter via `pane send-keys <pane_id> enter`, which needs the pane_id
-- resolved from `agent get <target>` (pane-level commands don't accept names).

local M = {}

--- Validate herdr availability; returns true if usable.
local function check_herdr()
	if vim.fn.executable("herdr") ~= 1 then
		vim.notify("herdr is not installed", vim.log.levels.ERROR)
		return false
	end
	if not vim.env.HERDR_ENV then
		vim.notify("Not inside a herdr session", vim.log.levels.ERROR)
		return false
	end
	return true
end

--- Run a herdr CLI subcommand and decode its single-line JSON response.
--- Returns the decoded table, or nil (with a notify) on shell/JSON failure.
local function run_herdr_json(args, error_msg)
	local output = vim.fn.system(args)
	if vim.v.shell_error ~= 0 then
		vim.notify(error_msg, vim.log.levels.ERROR)
		return nil
	end
	-- luanil maps JSON null to Lua nil (instead of the vim.NIL sentinel) so
	-- `agent.name or agent.terminal_id or agent.pane_id` fallbacks below work.
	local ok, decoded = pcall(vim.json.decode, output, { luanil = { object = true, array = true } })
	if not ok or type(decoded) ~= "table" then
		vim.notify(error_msg .. " (invalid response)", vim.log.levels.ERROR)
		return nil
	end
	if decoded.error then
		vim.notify(
			error_msg .. ": " .. (decoded.error.message or decoded.error.code or "unknown error"),
			vim.log.levels.ERROR
		)
		return nil
	end
	return decoded.result
end

--- List running agents as an array of selectable target strings (agent name,
--- falling back to terminal/pane id when the agent has no name).
local function list_agents()
	local result = run_herdr_json({ "herdr", "agent", "list" }, "Failed to list herdr agents")
	if not result or not result.agents then
		return {}
	end
	local targets = {}
	for _, agent in ipairs(result.agents) do
		local target = agent.name or agent.terminal_id or agent.pane_id
		if target then
			table.insert(targets, target)
		end
	end
	return targets
end

--- Resolve an agent target (name/terminal id) to its pane_id, or nil on failure.
local function resolve_pane_id(target)
	local result = run_herdr_json({ "herdr", "agent", "get", target }, "Failed to resolve pane for agent: " .. target)
	if not result or not result.agent then
		return nil
	end
	return result.agent.pane_id
end

--- Resolve a target agent and invoke `cb(name)`.
--- Prompts with vim.ui.select when there's more than one agent.
local function pick_agent(cb)
	local agents = list_agents()
	if #agents == 0 then
		vim.notify("No running herdr agents found", vim.log.levels.WARN)
		return
	end
	if #agents == 1 then
		cb(agents[1])
		return
	end
	vim.ui.select(agents, { prompt = "Send to herdr agent:" }, function(choice)
		if choice then
			cb(choice)
		end
	end)
end

--- Type text into the named agent's pane and submit it with Enter.
local function send_to_agent(name, text)
	if not text or vim.trim(text) == "" then
		vim.notify("Nothing to send", vim.log.levels.WARN)
		return
	end
	local pane_id = resolve_pane_id(name)
	if not pane_id then
		return
	end
	if not run_herdr_json({ "herdr", "agent", "send", name, text }, "Failed to send to agent: " .. name) then
		return
	end
	if
		not run_herdr_json(
			{ "herdr", "pane", "send-keys", pane_id, "enter" },
			"Sent text but failed to submit for agent: " .. name
		)
	then
		return
	end
	vim.notify("Sent to agent: " .. name, vim.log.levels.INFO)
end

--- Extract the current visual selection as a single string, or nil if empty.
local function get_visual_selection()
	local srow, scol = unpack(vim.api.nvim_buf_get_mark(0, "<"))
	local erow, ecol = unpack(vim.api.nvim_buf_get_mark(0, ">"))
	if srow == 0 or erow == 0 then
		return nil
	end
	if (srow > erow) or (srow == erow and scol > ecol) then
		srow, erow = erow, srow
		scol, ecol = ecol, scol
	end
	local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol, erow - 1, ecol + 1, {})
	local text = table.concat(lines, "\n")
	if text == "" then
		return nil
	end
	return text
end

--- Send the current visual selection to a picked agent.
function M.send_selection()
	if not check_herdr() then
		return
	end
	local text = get_visual_selection()
	if not text then
		vim.notify("No text selected", vim.log.levels.WARN)
		return
	end
	pick_agent(function(name)
		send_to_agent(name, text)
	end)
end

--- Prompt for free-form text and send it to a picked agent.
function M.send_prompt()
	if not check_herdr() then
		return
	end
	vim.ui.input({ prompt = "Herdr prompt: " }, function(input)
		if not input or vim.trim(input) == "" then
			return
		end
		pick_agent(function(name)
			send_to_agent(name, input)
		end)
	end)
end

--- Send the current line to a picked agent.
function M.send_current_line()
	if not check_herdr() then
		return
	end
	local line = vim.api.nvim_get_current_line()
	if not line or vim.trim(line) == "" then
		vim.notify("Current line is empty", vim.log.levels.WARN)
		return
	end
	pick_agent(function(name)
		send_to_agent(name, line)
	end)
end

--- Send the current buffer's file path to a picked agent.
function M.send_buffer_path()
	if not check_herdr() then
		return
	end
	local path = vim.api.nvim_buf_get_name(0)
	if not path or path == "" then
		vim.notify("Buffer has no file path", vim.log.levels.WARN)
		return
	end
	pick_agent(function(name)
		send_to_agent(name, path)
	end)
end

return M
