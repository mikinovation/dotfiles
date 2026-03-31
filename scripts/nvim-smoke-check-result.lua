-- Run after init.lua: check collected errors/warnings + lazy plugin state.
-- Reads _G._smoke_errors / _G._smoke_warnings populated by nvim-smoke-check-hook.lua.
-- Results are written to SMOKE_RESULT_FILE (prefixed ERROR:/WARN:) for the shell script.

-- Check :messages for Neovim internal errors (E*) that bypass vim.notify
local messages = vim.api.nvim_exec2("messages", { output = true }).output or ""
for line in messages:gmatch("[^\n]+") do
	if line:match("^E%d+:") then
		table.insert(_G._smoke_errors, line)
	elseif line:match("^W%d+:") then
		table.insert(_G._smoke_warnings, line)
	end
end

-- Check lazy.nvim plugin errors
local lok, lazy = pcall(require, "lazy")
if lok then
	for _, plugin in pairs(lazy.plugins()) do
		if plugin._.has_errors then
			table.insert(
				_G._smoke_errors,
				"lazy plugin error [" .. plugin.name .. "]: " .. tostring(plugin._.error or "unknown")
			)
		end
	end
end

-- Write prefixed results to a single file
local result_file = os.getenv("SMOKE_RESULT_FILE") or "/dev/null"
local f = io.open(result_file, "w")
if f then
	for _, msg in ipairs(_G._smoke_errors) do
		f:write("ERROR:" .. msg .. "\n")
	end
	for _, msg in ipairs(_G._smoke_warnings) do
		f:write("WARN:" .. msg .. "\n")
	end
	f:close()
end

-- Exit with appropriate code
if #_G._smoke_errors > 0 then
	vim.cmd("cquit 1")
elseif #_G._smoke_warnings > 0 then
	vim.cmd("cquit 2")
else
	vim.cmd("quit")
end
