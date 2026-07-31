return {
	-- Clipboard configuration for WSL. All logic lives in provider.lua.
	config = function()
		require("plugins.clipboard.provider").setup()
	end,
}
