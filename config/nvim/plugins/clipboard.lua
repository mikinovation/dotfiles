return {
	-- Clipboard configuration for WSL
	config = function()
		-- Check if we're in a WSL environment
		local is_wsl = vim.fn.has("wsl") == 1

		if is_wsl then
			-- Configure clipboard for WSL using clip.exe and PowerShell
			-- clip.exe expects UTF-16LE input, so convert from UTF-8 via iconv
			local copy_cmd = { "sh", "-c", "iconv -f UTF-8 -t UTF-16LE | clip.exe" }
			local paste_cmd = {
				"sh",
				"-c",
				"powershell.exe -NoProfile -Command "
					.. "'[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;"
					.. "[Console]::Out.Write($(Get-Clipboard -Raw)"
					.. '.tostring().replace("`r", ""))\'',
			}
			vim.g.clipboard = {
				name = "wsl-clipboard",
				copy = {
					["+"] = copy_cmd,
					["*"] = copy_cmd,
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
