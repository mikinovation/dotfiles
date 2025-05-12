local openBrowser = {}

function openBrowser.config()
	return {
		"tyru/open-browser.vim",
		config = function()
			-- Set keymaps for opening URLs
			vim.keymap.set("n", "gx", "<Plug>(openbrowser-smart-search)", { desc = "Open URL under cursor" })
			vim.keymap.set("v", "gx", "<Plug>(openbrowser-smart-search)", { desc = "Open selected URL" })
		end,
	}
end

return openBrowser
