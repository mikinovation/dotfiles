local dropbar = {}

function dropbar.config()
	return {
		"Bekaboo/dropbar.nvim",
		commit = "f7ecb0c3600ca1dc467c361e9af40f97289d7aad",
		-- optional, but required for fuzzy finder support
		dependencies = {
			require("plugins.telescope-fzf-native").config(),
		},
		config = function()
			local dropbar_api = require("dropbar.api")
			vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
			vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
			vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
		end,
	}
end

return dropbar
