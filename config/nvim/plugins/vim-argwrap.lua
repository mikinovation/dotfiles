local vimArgwrap = {}

function vimArgwrap.config()
	return {
		"FooSoft/vim-argwrap",
		config = function()
			-- Vim-Argwrap keymap
			vim.keymap.set("n", "<leader>aw", ":ArgWrap<CR>", { desc = "Argwrap" })
		end,
	}
end

return vimArgwrap
