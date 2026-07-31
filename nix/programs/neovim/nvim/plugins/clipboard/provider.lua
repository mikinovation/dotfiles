-- provider.lua
-- Clipboard provider selection for WSL.
--
-- WSLg exposes a Wayland compositor whose selection is kept in sync with the
-- Windows clipboard, and wl-clipboard talks to it directly. That path is ~30x
-- faster than shelling out to powershell.exe (25ms vs 734ms measured), which
-- matters because cache_enabled = 0 makes every register read hit the provider.
-- The clip.exe / powershell.exe path stays as a fallback for WSL without WSLg.

local M = {}

-- clip.exe expects UTF-16LE input, so convert from UTF-8 via iconv
local wsl_exe_copy = { "sh", "-c", "iconv -f UTF-8 -t UTF-16LE | clip.exe" }
local wsl_exe_paste = {
	"sh",
	"-c",
	"powershell.exe -NoProfile -Command "
		.. "'[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;"
		.. "$c = Get-Clipboard -Raw;"
		.. "if ($c -ne $null) {"
		.. '[Console]::Out.Write($c.tostring().replace("`r", ""))'
		.. "}'",
}

--- Pick the clipboard provider to use.
--- @return string|nil "wayland", "wsl-exe" or nil when neither applies
function M.detect()
	local wayland_display = vim.env.WAYLAND_DISPLAY

	if
		wayland_display
		and wayland_display ~= ""
		and vim.fn.executable("wl-copy") == 1
		and vim.fn.executable("wl-paste") == 1
	then
		return "wayland"
	end

	if vim.fn.has("wsl") == 1 then
		return "wsl-exe"
	end

	return nil
end

--- Build the vim.g.clipboard table for a provider kind.
--- @param kind string|nil result of M.detect()
--- @return table|nil nil when neovim's own detection should be left alone
function M.build(kind)
	if kind == "wayland" then
		return {
			name = "wl-clipboard",
			copy = {
				["+"] = { "wl-copy", "--type", "text/plain" },
				["*"] = { "wl-copy", "--primary", "--type", "text/plain" },
			},
			paste = {
				["+"] = { "wl-paste", "--no-newline", "--type", "text/plain" },
				["*"] = { "wl-paste", "--primary", "--no-newline", "--type", "text/plain" },
			},
			-- Must stay 0: yanky reads the "+" register on focus changes to pull
			-- clipboard content copied outside neovim into the yank ring.
			cache_enabled = 0,
		}
	end

	if kind == "wsl-exe" then
		return {
			name = "wsl-clipboard",
			copy = {
				["+"] = wsl_exe_copy,
				["*"] = wsl_exe_copy,
			},
			paste = {
				["+"] = wsl_exe_paste,
				["*"] = wsl_exe_paste,
			},
			cache_enabled = 0,
		}
	end

	return nil
end

--- Apply the detected provider to vim.g.clipboard.
function M.setup()
	local provider = M.build(M.detect())

	if provider then
		vim.g.clipboard = provider
	end
end

return M
