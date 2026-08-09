local gitlinker = {}

function gitlinker.config()
	return {
		"ruifm/gitlinker.nvim",
		-- Keep in sync with plugins/gitlinker/keymaps.lua (normal mode) and with
		-- gitlinker's own default mapping, which also covers visual mode.
		keys = {
			{ "<leader>gy", mode = { "n", "v" }, desc = "Copy git link to clipboard" },
		},
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("gitlinker").setup({
				opts = {
					add_current_line_on_normal_mode = true,
					action_callback = require("gitlinker.actions").copy_to_clipboard,
					print_url = true,
				},
				-- Disable default mappings, use keymaps.lua instead
				mappings = nil,
			})

			require("plugins.gitlinker.keymaps").setup()
		end,
	}
end

return gitlinker
