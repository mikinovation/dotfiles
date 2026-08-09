local vimArgwrap = {}

function vimArgwrap.config()
	return {
		"FooSoft/vim-argwrap",
		cmd = "ArgWrap",
		-- Keep in sync with plugins/vim-argwrap/keymaps.lua
		keys = {
			{ "<leader>aw", desc = "Argwrap" },
		},
		config = function()
			require("plugins.vim-argwrap.keymaps").setup()
		end,
	}
end

return vimArgwrap
