local vimFugitive = {}

function vimFugitive.config()
	return {
		"tpope/vim-fugitive",
		-- plugins/vim-fugitive/keymaps.lua registers ~40 <leader>g* mappings,
		-- too many to enumerate as lazy keys, so defer to just after startup.
		event = "VeryLazy",
		config = function()
			require("plugins.vim-fugitive.keymaps").setup()
		end,
	}
end

return vimFugitive
