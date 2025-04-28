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
					"~/projects/mikinovation/org/journal/**/*",
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
						target = "projects/mikinovation/org/journal/personal/%<%Y>.org",
					},
					w = {
						description = "Work Journal",
						template = "\n*** %<%Y-%m-%d> %<%A>\n**** %U\n\n%?",
						target = "projects/mikinovation/org/journal/work/%<%Y>.org",
					},
					t = {
						description = "Personal Task",
						template = "* TODO %?\n  %U",
						target = "projects/mikinovation/org/personal/tasks.org",
					},
					T = {
						description = "Work Task",
						template = "* TODO %?\n  %U",
						target = "projects/mikinovation/org/work/tasks.org",
					},
					m = {
						description = "Work Meeting",
						template = "* Meeting: %?\n  %U\n** Attendees\n\n** Agenda\n\n** Action Items\n",
						target = "projects/mikinovation/org/work/meetings.org",
					},
					i = {
						description = "Personal Idea",
						template = "* Idea: %?\n  %U\n  %a",
						target = "projects/mikinovation/org/personal/ideas.org",
					},
					I = {
						description = "Work Idea",
						template = "* Idea: %?\n  %U\n  %a",
						target = "projects/mikinovation/org/work/ideas.org",
					},
				},
			})

			local function custom_refile()
				local input = vim.fn.input("Refile to (p: personal, w: work): ")

				if input == "p" then
					-- Refile to personal file
					vim.cmd("Org refile projects/mikinovation/org/personal/refile.org")
				elseif input == "w" then
					-- Refile to work file
					vim.cmd("Org refile projects/mikinovation/org/work/refile.org")
				else
					-- Show normal refile prompt
					vim.cmd("Org refile")
				end
			end

			local function custom_capture()
				local input = vim.fn.input("Capture type (p: personal, w: work): ")

				if input == "p" then
					-- Show personal capture templates
					vim.cmd("Org capture j t i")
				elseif input == "w" then
					-- Show work capture templates
					vim.cmd("Org capture w T m I")
				else
					-- Show normal capture prompt
					vim.cmd("Org capture")
				end
			end

			-- Key mappings
			vim.api.nvim_set_keymap("n", "<Leader>or", ":lua custom_refile()<CR>", { noremap = true, silent = true })
			vim.api.nvim_set_keymap("n", "<Leader>oc", ":lua custom_capture()<CR>", { noremap = true, silent = true })
		end,
	}
end

return orgmode
