return {
	-- Clipboard configuration for WSL
	config = function()
		-- Check if we're in a WSL environment
		local is_wsl = vim.fn.has("wsl") == 1

		if is_wsl then
			-- Configure clipboard for WSL using clip.exe and PowerShell
			local paste_cmd = "powershell.exe -NoProfile -Command "
				.. "[Console]::Out.Write($(Get-Clipboard -Raw)"
				.. '.tostring().replace("`r", ""))'
			vim.g.clipboard = {
				name = "wsl-clipboard",
				copy = {
					["+"] = "clip.exe",
					["*"] = "clip.exe",
				},
				paste = {
					["+"] = paste_cmd,
					["*"] = paste_cmd,
				},
				cache_enabled = 0,
			}
		end
	end,
}
