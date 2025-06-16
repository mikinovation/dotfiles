local claudeCode = {}

function claudeCode.config()
	return {
		"greggh/claude-code.nvim",
		commit = "91b38f289c9b1f08007a0443020ed97bb7539ebe",
		dependencies = {
			require("plugins.plenary").config(),
		},
		config = function()
			local claude_client = require("config.nvim.plugins.claude_code.claude_client")

			require("claude-code").setup({
				window = {
					split_ratio = 0.5,
					position = "vertical",
					enter_insert = true,
					hide_numbers = true,
					hide_signcolumn = true,
				},
				refresh = {
					enable = true,
					updatetime = 100,
					timer_interval = 1000,
					show_notifications = true,
				},
				git = {
					use_git_root = true,
				},
				command = "claude",
				command_variants = {
					continue = "--continue",
					resume = "--resume",
					verbose = "--verbose",
				},
				keymaps = {
					toggle = {
						normal = "<C-,>",
						terminal = "<C-,>",
						variants = {
							continue = "<leader>cC",
							verbose = "<leader>cV",
						},
					},
					window_navigation = true,
					scrolling = true,
				},
			})

			local config = {
				languages = { "ja", "en" },
				draft_options = { "draft", "open" },
				ticket_required = false,
			}

			local function run_commit_with_claude(state)
				local instruction_builders = require("config.nvim.plugins.claude_code.instruction_builders")
				claude_client.send_to_claude(instruction_builders.build_commit_instruction(state))
			end

			local function run_issue_with_claude(state)
				local instruction_builders = require("config.nvim.plugins.claude_code.instruction_builders")
				claude_client.send_to_claude(instruction_builders.build_issue_instruction(state))
			end

			local function run_pr_with_claude(state)
				local instruction_builders = require("config.nvim.plugins.claude_code.instruction_builders")
				claude_client.send_to_claude(instruction_builders.build_pr_instruction(state))
			end

			local function run_push_with_claude(state)
				local instruction_builders = require("config.nvim.plugins.claude_code.instruction_builders")
				claude_client.send_to_claude(instruction_builders.build_push_instruction(state))
			end

			local function select_language(callback)
				vim.ui.select(config.languages, {
					prompt = "Select language:",
					format_item = function(item)
						return item
					end,
				}, function(language)
					if not language then
						return
					end
					callback({ language = language })
				end)
			end

			local function get_remote_branches()
				local git_operations = require("config.nvim.plugins.claude_code.git_operations")
				local branches = git_operations.get_remote_branches()
				if #branches == 0 then
					vim.notify("Error: No remote branches found.", vim.log.levels.ERROR)
					return {}
				end
				return branches
			end

			local function select_base_branch(state, callback)
				local branches = get_remote_branches()
				vim.ui.select(branches, {
					prompt = "Select base branch for PR:",
					format_item = function(item)
						return item
					end,
				}, function(base_branch)
					if not base_branch then
						callback(state)
						return
					end
					state.base_branch = base_branch
					callback(state)
				end)
			end

			vim.api.nvim_create_user_command("ClaudeCodeCreatePR", function()
				select_language(function(state)
					vim.ui.select(config.draft_options, {
						prompt = "Select PR status:",
						format_item = function(item)
							return item
						end,
					}, function(draft_mode)
						if not draft_mode then
							return
						end
						state.draft_mode = draft_mode

						select_base_branch(state, function(updated_state)
							vim.ui.input({
								prompt = config.ticket_required and "Enter ticket link:"
									or "Enter ticket link (optional):",
							}, function(ticket)
								updated_state.ticket = ticket or ""
								run_pr_with_claude(updated_state)
							end)
						end)
					end)
				end)
			end, { desc = "Create a PR using Claude Code" })

			vim.api.nvim_create_user_command("ClaudeCodeCommit", function()
				select_language(run_commit_with_claude)
			end, { desc = "Create a commit using Claude Code" })

			vim.api.nvim_create_user_command("ClaudeCodeIssue", function()
				select_language(run_issue_with_claude)
			end, { desc = "Create a GitHub issue using Claude Code" })

			vim.api.nvim_create_user_command("ClaudeCodePush", function()
				select_base_branch({}, run_push_with_claude)
			end, { desc = "Push changes using Claude Code" })

			local function run_create_branch_with_claude(state)
				local instruction_builders = require("config.nvim.plugins.claude_code.instruction_builders")
				claude_client.send_to_claude(instruction_builders.build_create_branch_instruction(state))
			end

			vim.api.nvim_create_user_command("ClaudeCodeCreateBranch", function()
				vim.ui.input({
					prompt = "Enter ticket title:",
				}, function(title)
					if not title or title == "" then
						vim.notify("Branch creation cancelled", vim.log.levels.INFO)
						return
					end

					run_create_branch_with_claude({ title = title })
				end)
			end, { desc = "Create a git branch using Claude Code" })

			-- Keymap
			vim.keymap.set("n", "<leader>cP", ":ClaudeCodeCreatePR<CR>", { desc = "Create a PR using Claude Code" })
			vim.keymap.set("n", "<leader>cM", ":ClaudeCodeCommit<CR>", { desc = "Create a commit using Claude Code" })
			vim.keymap.set(
				"n",
				"<leader>cI",
				":ClaudeCodeIssue<CR>",
				{ desc = "Create a GitHub issue using Claude Code" }
			)
			vim.keymap.set("n", "<leader>cS", ":ClaudeCodePush<CR>", { desc = "Push changes using Claude Code" })
			vim.keymap.set(
				"n",
				"<leader>cB",
				":ClaudeCodeCreateBranch<CR>",
				{ desc = "Create a git branch using Claude Code" }
			)
			-- File path integration functions

			local function get_current_file_path()
				local current_file = vim.api.nvim_buf_get_name(0)
				if current_file == "" then
					vim.notify("Current buffer has no file", vim.log.levels.WARN)
					return nil
				end

				local git_operations = require("config.nvim.plugins.claude_code.git_operations")
				return git_operations.get_relative_path(current_file)
			end

			-- Send current buffer file path to claude-code
			vim.api.nvim_create_user_command("ClaudeCodeSendCurrentFile", function()
				local current_file = get_current_file_path()
				if current_file then
					claude_client.send_file_paths_to_claude({ current_file })
				end
			end, { desc = "Send current file path to Claude Code" })

			-- Telescope integration for sending selected files
			local function telescope_send_files()
				local telescope_ok, _ = pcall(require, "telescope")
				if not telescope_ok then
					vim.notify("Telescope not available", vim.log.levels.ERROR)
					return
				end

				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local conf = require("telescope.config").values
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")

				local function send_selected_files(prompt_bufnr)
					local picker = action_state.get_current_picker(prompt_bufnr)
					local selections = picker:get_multi_selection()

					-- If no multi-selection, use the current selection
					if #selections == 0 then
						local selection = action_state.get_selected_entry()
						if selection then
							selections = { selection }
						end
					end

					actions.close(prompt_bufnr)

					local file_paths = {}
					for _, selection in ipairs(selections) do
						local file_path = selection.path or selection.value
						if file_path then
							table.insert(file_paths, file_path)
						end
					end

					claude_client.send_file_paths_to_claude(file_paths)
				end

				pickers
					.new({}, {
						prompt_title = "Send Files to Claude Code",
						finder = finders.new_oneshot_job({ "find", ".", "-type", "f" }, {
							entry_maker = function(entry)
								return {
									value = entry,
									path = entry,
									display = entry,
									ordinal = entry,
								}
							end,
						}),
						sorter = conf.generic_sorter({}),
						attach_mappings = function(_, map)
							actions.select_default:replace(send_selected_files)
							map("i", "<C-CR>", send_selected_files)
							map("n", "<C-CR>", send_selected_files)
							return true
						end,
					})
					:find()
			end

			vim.api.nvim_create_user_command("ClaudeCodeSendFiles", telescope_send_files, {
				desc = "Send selected files to Claude Code via Telescope",
			})

			vim.keymap.set(
				"n",
				"<leader>cf",
				":ClaudeCodeSendCurrentFile<CR>",
				{ desc = "Send current file to Claude Code" }
			)
			vim.keymap.set(
				"n",
				"<leader>cF",
				":ClaudeCodeSendFiles<CR>",
				{ desc = "Send files to Claude Code via Telescope" }
			)

			-- Line and range selection functions

			local function get_current_line_content()
				local current_line = vim.api.nvim_win_get_cursor(0)[1]
				local line_content = vim.api.nvim_buf_get_lines(0, current_line - 1, current_line, false)

				local file_path = get_current_file_path()
				local file_info = nil
				if file_path then
					file_info = {
						path = file_path,
						line_start = current_line,
						line_end = current_line,
					}
				end

				return line_content, file_info
			end

			local function get_visual_selection_content()
				local start_pos = vim.fn.getpos("'<")
				local end_pos = vim.fn.getpos("'>")
				local start_line = start_pos[2]
				local end_line = end_pos[2]

				local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

				local file_path = get_current_file_path()
				local file_info = nil
				if file_path then
					file_info = {
						path = file_path,
						line_start = start_line,
						line_end = end_line,
					}
				end

				return lines, file_info
			end

			vim.api.nvim_create_user_command("ClaudeCodeSendCurrentLine", function()
				local lines, file_info = get_current_line_content()
				claude_client.send_lines_to_claude(lines, file_info)
			end, { desc = "Send current line to Claude Code" })

			vim.api.nvim_create_user_command("ClaudeCodeSendSelection", function()
				local lines, file_info = get_visual_selection_content()
				claude_client.send_lines_to_claude(lines, file_info)
			end, { range = true, desc = "Send visual selection to Claude Code" })

			vim.keymap.set(
				"n",
				"<leader>cL",
				":ClaudeCodeSendCurrentLine<CR>",
				{ desc = "Send current line to Claude Code" }
			)
			vim.keymap.set(
				"v",
				"<leader>cL",
				":ClaudeCodeSendSelection<CR>",
				{ desc = "Send selection to Claude Code" }
			)
		end,
	}
end

return claudeCode
