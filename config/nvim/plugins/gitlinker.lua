local gitlinker = {}

function gitlinker.config()
	return {
		"ruifm/gitlinker.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitlinker").setup({
				opts = {
					-- remote: nil (automatically find the remote) or a specific string
					-- remote = "origin",
					-- adds current line on normal mode
					add_current_line_on_normal_mode = true,
					-- callback for what to do with the url
					action_callback = require("gitlinker.actions").copy_to_clipboard,
					-- print the url after action
					print_url = true,
				},
				-- default mapping to call url generation with action_callback
				mappings = "<leader>gy",
			})
		end,
	}
end

return gitlinker
