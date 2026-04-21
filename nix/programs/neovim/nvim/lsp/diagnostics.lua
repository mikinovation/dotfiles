-- lsp/diagnostics.lua

-- LSP diagnostic display settings (signs, floating windows, etc.)
vim.diagnostic.config({
	virtual_text = {
		prefix = "●", -- Customize icon
		severity = {
			min = vim.diagnostic.severity.WARN,
		},
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
	},
})

-- Customizing diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
