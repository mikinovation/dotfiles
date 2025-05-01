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
					r = {
						description = "Refile",
						template = "* TODO %?\n  %U",
						target = "~/projects/mikinovation/org/refile.org",
					},
					j = {
						description = "Personal Journal",
						template = "\n*** %<%y-%m-%d> %<%a>\n**** %u\n\n%?",
						target = "~/projects/mikinovation/org/personal/jounal/%<%y>.org",
					},
					w = {
						description = "Work Journal",
						template = "\n*** %<%Y-%m-%d> %<%A>\n**** %U\n\n%?",
						target = "~/projects/mikinovation/org/work/journal/%<%Y>.org",
					},
					t = {
						description = "Personal Task",
						template = "* TODO %?\n  %U",
						target = "~/projects/mikinovation/org/personal/tasks.org",
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
					n = {
						description = "Personal Note",
						template = "* %?\n  %U",
						target = "~/projects/mikinovation/org/personal/note.org",
					},
				},
			})

			local function ensure_dir_and_open(file_path)
				local dir_path = vim.fn.fnamemodify(file_path, ":h")
				vim.fn.system("mkdir -p " .. dir_path)
				-- Open the file in a split at the bottom
				vim.cmd("botright split " .. file_path)
				-- Set the height of the split (adjust the number as needed)
				vim.cmd("resize 15")
			end

			-- Personal org files
			vim.api.nvim_create_user_command("OrgPersonalNote", function()
				ensure_dir_and_open("~/projects/mikinovation/org/personal/note.org")
			end, { desc = "Edit personal note.org file" })

			vim.api.nvim_create_user_command("OrgPersonalTasks", function()
				ensure_dir_and_open("~/projects/mikinovation/org/personal/tasks.org")
			end, { desc = "Edit personal tasks.org file" })

			vim.api.nvim_create_user_command("OrgPersonalIdeas", function()
				ensure_dir_and_open("~/projects/mikinovation/org/personal/ideas.org")
			end, { desc = "Edit personal ideas.org file" })

			vim.api.nvim_create_user_command("OrgPersonalJournal", function()
				local date_format = os.date("%y")
				ensure_dir_and_open("~/projects/mikinovation/org/personal/jounal/" .. date_format .. ".org")
			end, { desc = "Edit personal journal file" })

			-- Work org files
			vim.api.nvim_create_user_command("OrgWorkTasks", function()
				ensure_dir_and_open("~/projects/mikinovation/org/work/tasks.org")
			end, { desc = "Edit work tasks.org file" })

			vim.api.nvim_create_user_command("OrgWorkIdeas", function()
				ensure_dir_and_open("~/projects/mikinovation/org/work/ideas.org")
			end, { desc = "Edit work ideas.org file" })

			vim.api.nvim_create_user_command("OrgWorkMeetings", function()
				ensure_dir_and_open("~/projects/mikinovation/org/work/meetings.org")
			end, { desc = "Edit work meetings.org file" })

			vim.api.nvim_create_user_command("OrgWorkJournal", function()
				local date_format = os.date("%Y")
				ensure_dir_and_open("~/projects/mikinovation/org/work/journal/" .. date_format .. ".org")
			end, { desc = "Edit work journal file" })

			vim.api.nvim_create_user_command("OrgRefile", function()
				ensure_dir_and_open("~/projects/mikinovation/org/refile.org")
			end, { desc = "Edit refile.org file" })

			vim.api.nvim_create_user_command("OrgNoteCapture", function()
				require("orgmode").action("capture.capture", { template = "n" })
			end, { desc = "Capture to personal note.org file" })

			vim.api.nvim_create_user_command("OrgOpenFile", function()
				local org_files = {
					{ name = "Personal Note", path = "~/projects/mikinovation/org/personal/note.org" },
					{ name = "Personal Tasks", path = "~/projects/mikinovation/org/personal/tasks.org" },
					{ name = "Personal Ideas", path = "~/projects/mikinovation/org/personal/ideas.org" },
					{
						name = "Personal Journal",
						path = "~/projects/mikinovation/org/personal/jounal/" .. os.date("%y") .. ".org",
					},
					{ name = "Work Tasks", path = "~/projects/mikinovation/org/work/tasks.org" },
					{ name = "Work Ideas", path = "~/projects/mikinovation/org/work/ideas.org" },
					{ name = "Work Meetings", path = "~/projects/mikinovation/org/work/meetings.org" },
					{
						name = "Work Journal",
						path = "~/projects/mikinovation/org/work/journal/" .. os.date("%Y") .. ".org",
					},
					{ name = "Refile", path = "~/projects/mikinovation/org/refile.org" },
				}

				-- Using vim.ui.select for a nice selection menu
				vim.ui.select(org_files, {
					prompt = "Select org file to open:",
					format_item = function(item)
						return item.name
					end,
				}, function(choice)
					if choice then
						ensure_dir_and_open(choice.path)
					end
				end)
			end, { desc = "Open org file selector" })

			-- Orgmode key mappings - Primary functions
			vim.keymap.set("n", "<leader>oo", ":OrgOpenFile<CR>", { desc = "[O]rgmode [O]pen file selector" })
			vim.keymap.set("n", "<leader>oc", ":OrgCapture<CR>", { desc = "[O]rgmode [C]apture" })
			vim.keymap.set("n", "<leader>oa", ":OrgAgenda<CR>", { desc = "[O]rgmode [A]genda" })

			-- Personal org files
			vim.keymap.set("n", "<leader>on", ":OrgPersonalNote<CR>", { desc = "[O]rgmode personal [N]ote" })
			vim.keymap.set("n", "<leader>ot", ":OrgPersonalTasks<CR>", { desc = "[O]rgmode personal [T]asks" })
			vim.keymap.set("n", "<leader>oi", ":OrgPersonalIdeas<CR>", { desc = "[O]rgmode personal [I]deas" })
			vim.keymap.set("n", "<leader>oj", ":OrgPersonalJournal<CR>", { desc = "[O]rgmode personal [J]ournal" })

			-- Work org files
			vim.keymap.set("n", "<leader>owt", ":OrgWorkTasks<CR>", { desc = "[O]rgmode [W]ork [T]asks" })
			vim.keymap.set("n", "<leader>owi", ":OrgWorkIdeas<CR>", { desc = "[O]rgmode [W]ork [I]deas" })
			vim.keymap.set("n", "<leader>owm", ":OrgWorkMeetings<CR>", { desc = "[O]rgmode [W]ork [M]eetings" })
			vim.keymap.set("n", "<leader>owj", ":OrgWorkJournal<CR>", { desc = "[O]rgmode [W]ork [J]ournal" })

			-- Other org files
			vim.keymap.set("n", "<leader>or", ":OrgRefile<CR>", { desc = "[O]rgmode [R]efile" })

			-- Quick capture to specific files
			vim.keymap.set("n", "<leader>onc", ":OrgNoteCapture<CR>", { desc = "[O]rgmode [N]ote [C]apture" })
		end,
	}
end

return orgmode
