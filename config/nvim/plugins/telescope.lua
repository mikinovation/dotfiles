local telescope = {}

function telescope.config()
	return { -- Fuzzy Finder (files, lsp, etc)
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			require("plugins.plenary").config(),
			require("plugins.telescope-fzf-native").config(),
			require("plugins.telescope-ui-select").config(),
			require("plugins.telescope-file-browser").config(),
			require("plugins.telescope-project").config(),
			require("plugins.telescope-repo").config(),
			require("plugins.telescope-frecency").config(),
			require("plugins.telescope-media-files").config(),
			require("plugins.nvim-web-devicons").config(),
		},
		config = function()
			local telescope_extensions = {
				"fzf",
				"ui-select",
				"file_browser",
				"project",
				"repo",
				"frecency",
				"media_files",
				"yank_history",
			}

			require("telescope").setup({
				defaults = {
					prompt_prefix = " ",
					selection_caret = "❯ ",
					path_display = { "truncate" },
					selection_strategy = "reset",
					sorting_strategy = "ascending",
					layout_strategy = "horizontal",
					layout_config = {
						horizontal = {
							prompt_position = "top",
							preview_width = 0.55,
							results_width = 0.8,
						},
						vertical = {
							mirror = false,
						},
						width = 0.8,
						height = 0.9,
						preview_cutoff = 120,
					},
					file_sorter = require("telescope.sorters").get_fzy_sorter,
					file_ignore_patterns = { "node_modules", ".git/", "dist/" },
					generic_sorter = require("telescope.sorters").get_fzy_sorter,
					winblend = 0,
					border = {},
					borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
					color_devicons = true,
					set_env = { ["COLORTERM"] = "truecolor" },
					mappings = {
						i = {
							["<C-j>"] = require("telescope.actions").move_selection_next,
							["<C-k>"] = require("telescope.actions").move_selection_previous,
							["<C-q>"] = require("telescope.actions").send_to_qflist
								+ require("telescope.actions").open_qflist,
							["<C-s>"] = require("telescope.actions").toggle_selection,
							["<C-u>"] = false,
							["<C-d>"] = false,
						},
					},
				},
				pickers = {
					find_files = {
						hidden = true,
					},
					live_grep = {
						additional_args = function()
							return { "--hidden" }
						end,
					},
					buffers = {
						show_all_buffers = true,
						sort_lastused = true,
						mappings = {
							i = {
								["<C-d>"] = require("telescope.actions").delete_buffer,
							},
						},
					},
				},
				extensions = {
					fzf = {
						fuzzy = true,
						override_generic_sorter = true,
						override_file_sorter = true,
						case_mode = "smart_case",
						-- Prioritize substring matches
						-- Available matching modes: 'prefix', 'suffix', 'exact', 'inverse-exact', 'inverse-prefix', 'inverse-suffix'
						-- Use default fuzzy matching but with tighter scoring for substring matches
					},
					file_browser = {
						-- theme = "dropdown",
						hijack_netrw = true,
						mappings = {
							["i"] = {
								["<C-w>"] = function()
									vim.cmd("normal vbd")
								end,
							},
						},
					},
					project = {
						base_dirs = {
							{ "~/projects", max_depth = 4 },
						},
						hidden_files = true,
						sync_with_nvim_tree = true,
					},
					frecency = {
						show_scores = true,
						show_unindexed = true,
						ignore_patterns = { "*.git/*", "*/tmp/*" },
						disable_devicons = false,
						workspaces = {
							["conf"] = "~/.config",
							["project"] = "~/projects",
						},
					},
				},
			})

			-- Highlight settings for harmonizing with colorscheme
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function()
					vim.api.nvim_set_hl(0, "TelescopePromptTitle", { link = "Title" })
					vim.api.nvim_set_hl(0, "TelescopePromptPrefix", { link = "Identifier" })
					vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "FloatBorder" })
					vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { link = "Title" })
					vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { link = "FloatBorder" })
					vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { link = "Title" })
					vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { link = "FloatBorder" })
				end,
			})

			-- Load extensions
			for _, ext in ipairs(telescope_extensions) do
				pcall(require("telescope").load_extension, ext)
			end

			-- Custom function to search within project (respects .gitignore)
			local function project_files()
				local opts = {}
				local ok = pcall(require("telescope.builtin").git_files, opts)
				if not ok then
					require("telescope.builtin").find_files(opts)
				end
			end

			-- Grep search for word under cursor
			local function grep_current_word()
				local word = vim.fn.expand("<cword>")
				require("telescope.builtin").grep_string({ search = word })
			end

			-- Search for text selected in visual mode
			local function grep_visual_selection()
				local function get_visual_selection()
					local s_start = vim.fn.getpos("'<")
					local s_end = vim.fn.getpos("'>")
					local n_lines = math.abs(s_end[2] - s_start[2]) + 1
					local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
					lines[1] = string.sub(lines[1], s_start[3], -1)
					if n_lines == 1 then
						lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
					else
						lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
					end
					return table.concat(lines, " ")
				end

				local text = get_visual_selection()
				require("telescope.builtin").grep_string({ search = text })
			end

			-- Search and replace in files
			local function search_and_replace()
				local word = vim.fn.expand("<cword>")
				local search_term = vim.fn.input("Search term: ", word)
				if search_term == "" then
					return
				end

				local replace_term = vim.fn.input("Replace with: ")
				if replace_term == "" then
					return
				end

				-- Display matching locations using Telescope
				require("telescope.builtin").grep_string({
					search = search_term,
					prompt_title = "Search: " .. search_term .. " → Replace: " .. replace_term,
					attach_mappings = function(_, map)
						map("i", "<CR>", function(prompt_bufnr)
							local confirmation = vim.fn.input("Execute? (y/n): ")
							if confirmation:lower() == "y" then
								vim.cmd("%s/" .. search_term .. "/" .. replace_term .. "/g")
								require("telescope.actions").close(prompt_bufnr)
							end
						end)
						return true
					end,
				})
			end

			-- Search for yanked text (from default register)
			local function grep_yanked_text()
				local yanked = vim.fn.getreg('"')
				-- Remove newlines and extra whitespace for cleaner search
				yanked = yanked:gsub("[\n\r]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
				if yanked == "" then
					vim.notify("No text in yank register", vim.log.levels.WARN)
					return
				end
				require("telescope.builtin").grep_string({ search = yanked })
			end

			-- Find files with yanked text as initial search
			local function find_files_yanked()
				local yanked = vim.fn.getreg('"')
				yanked = yanked:gsub("[\n\r]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
				require("telescope.builtin").find_files({ default_text = yanked })
			end

			-- Basic Telescope keymappings
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
			vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind Current [W]ord" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
			vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
			vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind [B]uffers" })

			-- Additional Telescope keymappings
			vim.keymap.set("n", "<leader>f/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[F]ind [/] Fuzzily in Current Buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>fn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[F]ind [N]eovim Files" })

			-- Extension keymappings
			vim.keymap.set("n", "<leader>fb", ":Telescope file_browser<CR>", { desc = "[F]ile [B]rowser" })

			-- Open home directory in file_browser
			vim.keymap.set("n", "<leader>fH", function()
				require("telescope").extensions.file_browser.file_browser({
					path = "~",
					cwd = "~",
					respect_gitignore = false,
					hidden = true,
					grouped = true,
					previewer = false,
					initial_mode = "normal",
					layout_config = { height = 40 },
				})
			end, { desc = "[F]ile Browser - [H]ome Directory" })

			vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "[F]ind [C]ommands" })
			vim.keymap.set("n", "<leader>fm", ":Telescope media_files<CR>", { desc = "[F]ind [M]edia Files" })
			vim.keymap.set("n", "<leader>sf", ":Telescope frecency<CR>", { desc = "[S]earch [F]requent Files" })

			-- Git integration
			vim.keymap.set("n", "<leader>gs", builtin.git_status, { desc = "[G]it [S]tatus" })
			vim.keymap.set("n", "<leader>gc", builtin.git_commits, { desc = "[G]it [C]ommits" })
			vim.keymap.set("n", "<leader>gb", builtin.git_branches, { desc = "[G]it [B]ranches" })

			-- Custom function keymappings
			vim.keymap.set("n", "<leader>pf", project_files, { desc = "[P]roject [F]iles" })
			vim.keymap.set("n", "<leader>sw", grep_current_word, { desc = "[S]earch Current [W]ord" })
			vim.keymap.set("v", "<leader>sw", grep_visual_selection, { desc = "[S]earch Selected [W]ord" })
			vim.keymap.set("n", "<leader>sr", search_and_replace, { desc = "[S]earch and [R]eplace" })
			vim.keymap.set("n", "<leader>fyg", grep_yanked_text, { desc = "[F]ind [Y]anked Text (Grep)" })
			vim.keymap.set("n", "<leader>fyf", find_files_yanked, { desc = "[F]ind [Y]anked Text (Files)" })
		end,
	}
end

return telescope
