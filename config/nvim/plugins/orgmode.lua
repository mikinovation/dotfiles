local orgmode = {}

function orgmode.config()
	return {
		"nvim-orgmode/orgmode",
		event = "VeryLazy",
		config = function()
			require("orgmode").setup({
				org_agenda_files = { "~/projects/org/**/*" },
				org_default_notes_file = "~/projects/org/refile.org",
			})
		end,
		mappings = {
			org = {
				org_global_cycle = "<leader>zz",
			},
		},
	}
end

return orgmode
