local diffview = {}

function diffview.config()
	return {
		"sindrets/diffview.nvim",
		config = function()
			require("diffview").setup({})
			require("plugins.diffview.keymaps").setup()
		end,
	}
end

return diffview
