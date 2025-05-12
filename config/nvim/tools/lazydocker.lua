local M = {}

-- Function to check if lazydocker is installed
function M.is_lazydocker_available()
	local handle = io.popen("which lazydocker 2>/dev/null")
	if not handle then
		return false
	end

	local result = handle:read("*a")
	handle:close()

	return result ~= ""
end

-- Function to create a floating terminal window
local function create_floating_window()
	-- Get editor size
	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	-- Calculate float size (80% of editor size)
	local win_width = math.ceil(width * 0.8)
	local win_height = math.ceil(height * 0.8)

	-- Calculate starting position
	local row = math.ceil((height - win_height) / 2)
	local col = math.ceil((width - win_width) / 2)

	-- Set window options
	local opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}

	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- Create window
	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Return both buffer and window IDs
	return buf, win
end

-- Function to launch lazydocker in a floating terminal window
function M.open_lazydocker()
	if not M.is_lazydocker_available() then
		vim.notify("lazydocker is not installed. Please install it first.", vim.log.levels.ERROR)
		return
	end

	-- Create a floating window
	local buf, _ = create_floating_window()

	-- Set buffer options
	vim.bo[buf].buflisted = false
	vim.bo[buf].modifiable = true
	vim.bo[buf].bufhidden = "wipe"

	-- Set buffer name
	vim.api.nvim_buf_set_name(buf, "lazydocker")

	-- Open terminal with lazydocker
	vim.fn.termopen("lazydocker", {
		on_exit = function()
			-- Close buffer when lazydocker exits
			if vim.api.nvim_buf_is_valid(buf) then
				vim.api.nvim_buf_delete(buf, { force = true })
			end
		end,
	})

	-- Start in insert mode
	vim.cmd("startinsert")
end

-- Function to toggle lazydocker (open or close)
function M.toggle_lazydocker()
	local lazydocker_buf = nil

	-- Check if lazydocker buffer is already open
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_get_name(buf):match("lazydocker$") then
			lazydocker_buf = buf
			break
		end
	end

	if lazydocker_buf and vim.api.nvim_buf_is_valid(lazydocker_buf) then
		-- If lazydocker is open, close it
		local win_id = vim.fn.bufwinid(lazydocker_buf)
		if win_id ~= -1 then
			vim.api.nvim_win_close(win_id, true)
		end
	else
		-- Otherwise, open lazydocker
		M.open_lazydocker()
	end
end

return M
