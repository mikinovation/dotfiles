local orgmode = {}

function orgmode.config()
	return {
		"nvim-orgmode/orgmode",
		event = "VeryLazy",
		config = function()
			require("orgmode").setup({
				org_agenda_files = { "~/projects/org/**/*" },
				org_default_notes_file = "~/projects/org/refile.org",
				org_tags_column = 20,
				org_use_tag_inheritance = true,
				org_tags_exclude_from_inheritance = {},
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
