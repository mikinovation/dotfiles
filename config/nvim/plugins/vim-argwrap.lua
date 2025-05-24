local vimArgwrap = {}

function vimArgwrap.config()
	return {
		"FooSoft/vim-argwrap",
		commit = "f3e26a5ad249d09467804b92e760d08b1cc457a1",
		config = function()
			-- Vim-Argwrap keymap
			vim.keymap.set("n", "<leader>aw", ":ArgWrap<CR>", { desc = "Argwrap" })
		end,
	}
end

return vimArgwrap
