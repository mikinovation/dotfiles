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
	local win_dir = vim.fn.system({ "wslpath", "-w", dir }):gsub("\n", "")
	vim.fn.system({ "explorer.exe", win_dir })
end

--- Toggle the lazydocker floating terminal.
function M.toggle_lazydocker()
	require("tools.lazydocker").toggle_lazydocker()
end

return M
