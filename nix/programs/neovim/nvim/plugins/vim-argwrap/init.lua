local vimArgwrap = {}

function vimArgwrap.config()
	return {
		"FooSoft/vim-argwrap",
		config = function()
			require("plugins.vim-argwrap.keymaps").setup()
		end,
	}
end

return vimArgwrap
