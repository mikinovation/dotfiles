local gitConflict = {}

function gitConflict.config()
	return {
		"akinsho/git-conflict.nvim",
		version = "2.0.0",
		config = function()
			require("git-conflict").setup({
				default_mappings = false,
			})

			require("plugins.git-conflict.keymaps").setup()
		end,
	}
end

return gitConflict
