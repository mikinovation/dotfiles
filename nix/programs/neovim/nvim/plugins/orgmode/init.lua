local orgmode = {}

function orgmode.config()
	return {
		"nvim-orgmode/orgmode",
		event = "VeryLazy",
		config = function()
			require("orgmode").setup({
				org_agenda_files = { "~/ghq/github.com/mikinovation/org/**/*" },
				org_default_notes_file = "~/ghq/github.com/mikinovation/org/refile.org",
				org_tags_column = 20,
				org_use_tag_inheritance = true,
				org_tags_exclude_from_inheritance = {},
				org_capture_templates = {
					n = {
						description = "Note",
						template = "* %?\n  [[%^{Link}]]",
						target = "~/ghq/github.com/mikinovation/org/refile.org",
					},
					t = {
						description = "Task",
						template = "* TODO %?\n  SCHEDULED: %t\n  [[%^{Link}]]",
						target = "~/ghq/github.com/mikinovation/org/refile.org",
					},
					c = {
						description = "Chat Reply",
						template = "* TODO Reply to %?\n  SCHEDULED: %t\n  [[%^{Link}]]",
						target = "~/ghq/github.com/mikinovation/org/refile.org",
					},
					m = {
						description = "Meeting",
						template = "* TODO Meeting: %?\n  SCHEDULED: %t\n  [[%^{Link}]]",
						target = "~/ghq/github.com/mikinovation/org/refile.org",
					},
				},
				mappings = {
					org = {
						org_global_cycle = "<leader>zz",
						org_open_at_point = "<CR>",
					},
				},
			})

			require("plugins.orgmode.keymaps").setup()
		end,
	}
end

return orgmode
