local openBrowser = {}

function openBrowser.config()
	return {
		"tyru/open-browser.vim",
		-- Keep in sync with plugins/open-browser/keymaps.lua
		keys = {
			{ "gx", desc = "Open URL under cursor" },
			{ "gx", mode = "v", desc = "Open selected URL" },
		},
		config = function()
			require("plugins.open-browser.keymaps").setup()
		end,
	}
end

return openBrowser
