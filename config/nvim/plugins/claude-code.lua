local claudeCode = {}

function claudeCode.config()
	return {
		"greggh/claude-code.nvim",
		dependencies = {
			require("plugins.plenary").config(),
		},
		config = function()
			local claude_client = require("plugins.claude_code.claude_client")

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

			local function run_create_branch_with_claude(state)
				local instruction_builders = require("plugins.claude_code.instruction_builders")
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

				local git_operations = require("plugins.claude_code.git_operations")
				return git_operations.get_relative_path(current_file)
			end

			-- Send current buffer file path to claude-code
			vim.api.nvim_create_user_command("ClaudeCodeSendCurrentFile", function()
				local current_file = get_current_file_path()
				if current_file then
					claude_client.send_file_paths_to_claude({ current_file })
				end
			end, { desc = "Send current file path to Claude Code" })

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
				local _, file_info = get_current_line_content()
				claude_client.send_lines_to_claude(file_info)
			end, { desc = "Send current line to Claude Code" })

			vim.api.nvim_create_user_command("ClaudeCodeSendSelection", function()
				local _, file_info = get_visual_selection_content()
				claude_client.send_lines_to_claude(file_info)
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
