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
				directory = "~/ghq/github.com/mikinovation/mikinovation/roam",
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
		end,
	}
end

return orgRoam
