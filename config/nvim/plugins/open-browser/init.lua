local openBrowser = {}

function openBrowser.config()
	return {
		"tyru/open-browser.vim",
		config = function()
			require("plugins.open-browser.keymaps").setup()
		end,
	}
end

return openBrowser
