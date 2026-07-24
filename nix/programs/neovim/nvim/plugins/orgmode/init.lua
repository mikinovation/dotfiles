local orgmode = {}

function orgmode.config()
	return {
		"nvim-orgmode/orgmode",
		event = "VeryLazy",
		config = function()
			require("orgmode").setup({})

			require("plugins.orgmode.keymaps").setup()
		end,
	}
end

return orgmode
