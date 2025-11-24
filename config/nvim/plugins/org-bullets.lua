local orgBullets = {}

function orgBullets.config()
	return {
		"nvim-orgmode/org-bullets.nvim",
		dependencies = { "nvim-orgmode/orgmode" },
		event = "VeryLazy",
		config = function()
			require("org-bullets").setup({})
		end,
	}
end

return orgBullets
