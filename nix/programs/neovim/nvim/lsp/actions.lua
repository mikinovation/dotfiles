-- lsp/actions.lua
-- LSP-related action functions invoked by buffer-local keymaps.

local M = {}

--- Asynchronously format the current buffer via the active LSP client(s).
function M.format_document()
	vim.lsp.buf.format({ async = true })
end

return M
