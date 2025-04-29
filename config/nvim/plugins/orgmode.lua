local orgmode = {}

function orgmode.config()
	return {
		"nvim-orgmode/orgmode",
		event = "VeryLazy",
		ft = { "org" },
		config = function()
			require("orgmode").setup({
				org_agenda_files = {
					"~/projects/mikinovation/org/personal/**/*",
					"~/projects/mikinovation/org/work/**/*",
				},
				org_default_notes_file = "~/projects/mikinovation/org/refile.org",
				org_todo_keywords = { "TODO(t)", "NEXT(n)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" },
				org_todo_keyword_faces = {
					WAITING = ":foreground blue :weight bold",
					CANCELLED = ":foreground gray :weight bold",
				},
				org_capture_templates = {
					j = {
						description = "Personal Journal",
						template = "\n*** %<%Y-%m-%d> %<%A>\n**** %U\n\n%?",
						target = "~/projects/mikinovation/org/personal/jounal/%<%Y>.org",
					},
					w = {
						description = "Work Journal",
						template = "\n*** %<%Y-%m-%d> %<%A>\n**** %U\n\n%?",
						target = "~/projects/mikinovation/org/work/journal/%<%Y>.org",
					},
					t = {
						description = "Personal Task",
						template = "* TODO %?\n  %U",
						target = "~/projects/mikinovation/personal/tasks.org",
					},
					T = {
						description = "Work Task",
						template = "* TODO %?\n  %U",
						target = "~/projects/mikinovation/org/work/tasks.org",
					},
					m = {
						description = "Work Meeting",
						template = "* Meeting: %?\n  %U\n** Attendees\n\n** Agenda\n\n** Action Items\n",
						target = "~/projects/mikinovation/org/work/meetings.org",
					},
					i = {
						description = "Personal Idea",
						template = "* Idea: %?\n  %U\n  %a",
						target = "~/projects/mikinovation/org/personal/ideas.org",
					},
					I = {
						description = "Work Idea",
						template = "* Idea: %?\n  %U\n  %a",
						target = "~/projects/mikinovation/org/work/ideas.org",
					},
				},
			})
		end,
	}
end

return orgmode
