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
				org_capture_templates = {
					n = {
						description = "Note",
						template = "* %?\n  [[%^{Link}]]",
						target = "~/projects/org/refile.org",
					},
					t = {
						description = "Task",
						template = "* TODO %?\n  SCHEDULED: %t\n  [[%^{Link}]]",
						target = "~/projects/org/refile.org",
					},
					c = {
						description = "Chat Reply",
						template = "* TODO Reply to %?\n  SCHEDULED: %t\n  [[%^{Link}]]",
						target = "~/projects/org/refile.org",
					},
					m = {
						description = "Meeting",
						template = "* TODO Meeting: %?\n  SCHEDULED: %t\n  [[%^{Link}]]",
						target = "~/projects/org/refile.org",
					},
				},
			})

			vim.keymap.set("n", "<leader>or", "<cmd>edit ~/projects/org/refile.org<CR>", { desc = "Open refile.org" })
		end,
		mappings = {
			org = {
				org_global_cycle = "<leader>zz",
			},
		},
	}
end

return orgmode
