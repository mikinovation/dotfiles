local orgRoam = {}

function orgRoam.config()
	return {
		"chipsenkbeil/org-roam.nvim",
		tag = "0.2.0",
		dependencies = {
			"nvim-orgmode/orgmode",
		},
		event = "VeryLazy",
		config = function()
			require("org-roam").setup({
				directory = "~/ghq/github.com/mikinovation/org/roam",
				org_files = {
					"~/ghq/github.com/mikinovation/org",
				},
			})
		end,
	}
end

return orgRoam
