-- tools/difit.lua
-- Launch the difit web UI from inside Neovim, picking the base branch via telescope.

local M = {}

local current_job = nil

function M.is_available()
	return vim.fn.executable("difit") == 1
end

function M.is_running()
	if not current_job then
		return false
	end
	-- jobwait with timeout 0 returns -1 for a still-running job.
	return vim.fn.jobwait({ current_job }, 0)[1] == -1
end

function M.list_branches()
	local refs = vim.fn.systemlist({
		"git",
		"for-each-ref",
		"--format=%(refname:short)",
		"refs/heads",
		"refs/remotes",
	})
	if vim.v.shell_error ~= 0 then
		return {}
	end
	local result = {}
	for _, ref in ipairs(refs) do
		if ref ~= "" and not ref:match("/HEAD$") then
			table.insert(result, ref)
		end
	end
	return result
end

function M.start(base)
	if not M.is_available() then
		vim.notify("difit is not installed.", vim.log.levels.ERROR)
		return
	end
	if M.is_running() then
		vim.notify(
			"difit is already running (job " .. tostring(current_job) .. "). Run :DifitStop first.",
			vim.log.levels.WARN
		)
		return
	end
	local job = vim.fn.jobstart({ "difit", "@", base }, {
		on_exit = function(_, code)
			current_job = nil
			vim.schedule(function()
				vim.notify("difit exited (code " .. tostring(code) .. ")", vim.log.levels.INFO)
			end)
		end,
	})
	if job <= 0 then
		current_job = nil
		vim.notify("Failed to start difit", vim.log.levels.ERROR)
		return
	end
	current_job = job
	vim.notify("difit started against " .. base, vim.log.levels.INFO)
end

function M.stop()
	if not current_job then
		vim.notify("difit is not running", vim.log.levels.INFO)
		return
	end
	vim.fn.jobstop(current_job)
	current_job = nil
end

function M.pick_base_and_start()
	if not M.is_available() then
		vim.notify("difit is not installed.", vim.log.levels.ERROR)
		return
	end
	local branches = M.list_branches()
	if #branches == 0 then
		vim.notify("No git branches found (is this a git repository?)", vim.log.levels.WARN)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local telescope_actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "difit: select base",
			finder = finders.new_table({ results = branches }),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, _)
				telescope_actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					telescope_actions.close(prompt_bufnr)
					if selection and selection.value then
						M.start(selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end

return M
