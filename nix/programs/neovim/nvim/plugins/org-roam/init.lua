local orgRoam = {}

local ROAM_DIRECTORY = "~/ghq/github.com/mikinovation/mikinovation/roam"

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
				directory = ROAM_DIRECTORY,
				org_files = {
					"~/ghq/github.com/mikinovation/org",
				},
				templates = {
					d = {
						description = "default",
						template = table.concat({
							"#+begin_src yaml",
							"type:",
							"description:",
							"tags: []",
							"timestamp: %<%Y-%m-%dT%H:%M:%S%z>",
							"#+end_src",
							"",
							"%?",
						}, "\n"),
						target = "%<%Y%m%d%H%M%S>-%[slug].org",
					},
				},
			})
			require("plugins.org-roam.keymaps").setup(ROAM_DIRECTORY)
		end,
	}
end

return orgRoam
