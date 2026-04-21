local vimFugitive = {}

function vimFugitive.config()
	return {
		"tpope/vim-fugitive",
		config = function()
			require("plugins.vim-fugitive.keymaps").setup()
		end,
	}
end

return vimFugitive
