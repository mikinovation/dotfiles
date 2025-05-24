local openBrowser = {}

function openBrowser.config()
	return {
		"tyru/open-browser.vim",
		commit = "7d4c1d8198e889d513a030b5a83faa07606bac27",
		config = function()
			-- Set keymaps for opening URLs
			vim.keymap.set("n", "gx", "<Plug>(openbrowser-smart-search)", { desc = "Open URL under cursor" })
			vim.keymap.set("v", "gx", "<Plug>(openbrowser-smart-search)", { desc = "Open selected URL" })
		end,
	}
end

return openBrowser
