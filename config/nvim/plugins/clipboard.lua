return {
	-- Clipboard configuration for WSL
	config = function()
		-- Check if we're in a WSL environment
		local is_wsl = vim.fn.has("wsl") == 1

		if is_wsl then
			-- Configure clipboard for WSL
			vim.g.clipboard = {
				name = "win32yank",
				copy = {
					["+"] = "win32yank.exe -i --crlf",
					["*"] = "win32yank.exe -i --crlf",
				},
				paste = {
					["+"] = "win32yank.exe -o --lf",
					["*"] = "win32yank.exe -o --lf",
				},
				cache_enabled = 0,
			}
		end
	end,
}