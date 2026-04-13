-- actions.lua
-- Global action functions invoked by keymaps.
-- Keep keymap files free of inline logic by defining actions here.

local M = {}

--- Format the current buffer using the active LSP client(s).
function M.format_document()
	vim.lsp.buf.format({ async = true })
end

--- Open the directory of the current file in Windows Explorer (WSL).
function M.open_in_explorer()
	local dir = vim.fn.expand("%:p:h")

	local win_dir = vim.fn.system({ "wslpath", "-w", dir })
	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to translate path via wslpath: " .. dir, vim.log.levels.ERROR)
		return
	end
	-- wslpath output can include trailing \n or \r\n; strip all trailing whitespace.
	win_dir = win_dir:gsub("%s+$", "")

	vim.fn.system({ "explorer.exe", win_dir })
	if vim.v.shell_error ~= 0 then
		vim.notify("Failed to open Windows Explorer at: " .. win_dir, vim.log.levels.ERROR)
		return
	end
end

--- Toggle the lazydocker floating terminal.
function M.toggle_lazydocker()
	require("tools.lazydocker").toggle_lazydocker()
end

return M
