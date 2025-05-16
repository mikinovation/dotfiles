local claudeCode = {}

function claudeCode.config()
	return {
		"greggh/claude-code.nvim",
		dependencies = {
			require("plugins.plenary").config(),
		},
		config = function()
			require("claude-code").setup({
				-- Terminal window settings
				window = {
					split_ratio = 0.5, -- Percentage of screen for the terminal window
					-- (height for horizontal, width for vertical splits)
					position = "vertical", -- Position of the window: "botright", "topleft", "vertical", "rightbelow vsplit", etc.
					enter_insert = true, -- Whether to enter insert mode when opening Claude Code
					hide_numbers = true, -- Hide line numbers in the terminal window
					hide_signcolumn = true, -- Hide the sign column in the terminal window
				},
				-- File refresh settings
				refresh = {
					enable = true, -- Enable file change detection
					updatetime = 100, -- updatetime when Claude Code is active (milliseconds)
					timer_interval = 1000, -- How often to check for file changes (milliseconds)
					show_notifications = true, -- Show notification when files are reloaded
				},
				-- Git project settings
				git = {
					use_git_root = true, -- Set CWD to git root when opening Claude Code (if in git project)
				},
				-- Command settings
				command = "claude", -- Command used to launch Claude Code
				-- Command variants
				command_variants = {
					-- Conversation management
					continue = "--continue", -- Resume the most recent conversation
					resume = "--resume", -- Display an interactive conversation picker

					-- Output options
					verbose = "--verbose", -- Enable verbose logging with full turn-by-turn output
				},
				-- Keymaps
				keymaps = {
					toggle = {
						normal = "<C-,>", -- Normal mode keymap for toggling Claude Code, false to disable
						terminal = "<C-,>", -- Terminal mode keymap for toggling Claude Code, false to disable
						variants = {
							continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
							verbose = "<leader>cV", -- Normal mode keymap for Claude Code with verbose flag
						},
					},
					window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
					scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
				},
			})

			-- Custom configuration for PR creation, commit, and issue
			local claude_config = {
				languages = { "ja", "en" },
				draft_options = { "draft", "open" },
				ticket_required = false,
			}

			-- Commit creation helper function
			local commit_with_claude = function(state)
				-- Create commit instruction
				local instruction_parts = {
					"I'm going to create a git commit. Please follow these instructions:",
					"- Create a commit in " .. state.language .. " language",
					"- Follow conventional commits format (e.g., `feat:`, `fix:`, `chore:`)",
					"- Use git status to see what files have changed",
					"- Use git diff to understand the changes",
					"- Create the commit using git commit -m with an appropriate message",
					"- Do NOT add any AI attribution lines to the commit message",
				}

				local instruction_text = table.concat(instruction_parts, "\n")
				local claude_code_module = require("claude-code")
				local bufnr = claude_code_module.claude_code.bufnr
				local window_exists = false

				if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
					local win_ids = vim.fn.win_findbuf(bufnr)
					window_exists = #win_ids > 0
				end

				if not window_exists then
					vim.cmd("ClaudeCode")
				end

				vim.defer_fn(function()
					local updated_bufnr = claude_code_module.claude_code.bufnr
					if updated_bufnr and vim.api.nvim_buf_is_valid(updated_bufnr) then
						local chan_id = vim.api.nvim_buf_get_var(updated_bufnr, "terminal_job_id")
						if chan_id then
							vim.api.nvim_chan_send(chan_id, instruction_text)
						end
					end
				end, window_exists and 100 or 1000) -- Shorter delay if window already exists
			end

			-- Issue creation helper function
			local create_issue_with_claude = function(state)
				-- Create Issue instruction
				local instruction_parts = {
					"I'm going to create a GitHub issue. I will use gh command. Please follow these instructions:",
					"- Create an issue in " .. state.language .. " language",
					"- Use gh issue create command to create the issue",
				}

				-- Check for issue template existence
				local function check_template_exists()
					local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
					if not handle then
						return false
					end
					local git_root = handle:read("*a"):gsub("%s+$", "")
					handle:close()
					if git_root == "" then
						return false
					end

					local template_path = git_root .. "/.github/ISSUE_TEMPLATE"
					local file = io.open(template_path, "r")
					if file then
						file:close()
						return true
					end
					return false
				end

				local template_exists = check_template_exists()
				if template_exists then
					table.insert(
						instruction_parts,
						"- Please check if there are templates in .github/ISSUE_TEMPLATE and use the appropriate template"
					)
				end

				local instruction_text = table.concat(instruction_parts, "\n")
				local claude_code_module = require("claude-code")
				local bufnr = claude_code_module.claude_code.bufnr
				local window_exists = false

				if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
					local win_ids = vim.fn.win_findbuf(bufnr)
					window_exists = #win_ids > 0
				end

				if not window_exists then
					vim.cmd("ClaudeCode")
				end

				vim.defer_fn(function()
					local updated_bufnr = claude_code_module.claude_code.bufnr
					if updated_bufnr and vim.api.nvim_buf_is_valid(updated_bufnr) then
						local chan_id = vim.api.nvim_buf_get_var(updated_bufnr, "terminal_job_id")
						if chan_id then
							vim.api.nvim_chan_send(chan_id, instruction_text)
						end
					end
				end, window_exists and 100 or 1000) -- Shorter delay if window already exists
			end

			-- PR creation helper function (defined before it's used)
			local create_pr_with_claude = function(state)
				-- Create PR instruction
				local instruction_parts = {
					"I'm going to create a pull request. I will use gh command. Please follow these instructions:",
					"- Create a PR in " .. state.language .. " language",
					"- Set PR status to " .. (state.draft_mode == "draft" and "draft" or "open"),
				}

				-- Add ticket information if available
				if state.ticket and state.ticket ~= "" then
					table.insert(instruction_parts, "- With ticket reference: " .. state.ticket)
				end

				-- Check for PR template existence
				local function check_template_exists()
					local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
					if not handle then
						return false
					end
					local git_root = handle:read("*a"):gsub("%s+$", "")
					handle:close()
					if git_root == "" then
						return false
					end

					local template_path = git_root .. "/.github/PULL_REQUEST_TEMPLATE.md"
					local file = io.open(template_path, "r")
					if file then
						file:close()
						return true
					end
					return false
				end

				local template_exists = check_template_exists()
				if template_exists then
					table.insert(
						instruction_parts,
						"- Please follow the template format in .github/PULL_REQUEST_TEMPLATE.md"
					)
				else
					table.insert(
						instruction_parts,
						"- Please check if .github/PULL_REQUEST_TEMPLATE.md exists and follow that template format if found"
					)
				end

				local instruction_text = table.concat(instruction_parts, "\n")
				local claude_code_module = require("claude-code")
				local bufnr = claude_code_module.claude_code.bufnr
				local window_exists = false

				if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
					local win_ids = vim.fn.win_findbuf(bufnr)
					window_exists = #win_ids > 0
				end

				if not window_exists then
					vim.cmd("ClaudeCode")
				end

				vim.defer_fn(function()
					local updated_bufnr = claude_code_module.claude_code.bufnr
					if updated_bufnr and vim.api.nvim_buf_is_valid(updated_bufnr) then
						local chan_id = vim.api.nvim_buf_get_var(updated_bufnr, "terminal_job_id")
						if chan_id then
							vim.api.nvim_chan_send(chan_id, instruction_text)
						end
					end
				end, window_exists and 100 or 1000) -- Shorter delay if window already exists
			end

			vim.api.nvim_create_user_command("ClaudeCodeCreatePR", function()
				local state = {
					language = nil,
					draft_mode = nil,
					ticket = nil,
				}

				-- Language selection
				vim.ui.select(claude_config.languages, {
					prompt = "Select PR language:",
					format_item = function(item)
						return item
					end,
				}, function(language)
					if not language then
						return
					end
					state.language = language

					-- Draft/Open selection
					vim.ui.select(claude_config.draft_options, {
						prompt = "Select PR status:",
						format_item = function(item)
							return item
						end,
					}, function(draft_mode)
						if not draft_mode then
							return
						end
						state.draft_mode = draft_mode

						-- Ticket link input (optional)
						if claude_config.ticket_required then
							vim.ui.input({
								prompt = "Enter ticket link:",
							}, function(ticket)
								state.ticket = ticket or ""
								create_pr_with_claude(state)
							end)
						else
							vim.ui.input({
								prompt = "Enter ticket link (optional):",
							}, function(ticket)
								state.ticket = ticket or ""
								create_pr_with_claude(state)
							end)
						end
					end)
				end)
			end, { desc = "Create a PR using Claude Code" })

			-- Create :ClaudeCodeCommit command
			vim.api.nvim_create_user_command("ClaudeCodeCommit", function()
				local state = {
					language = nil,
				}

				-- Language selection
				vim.ui.select(claude_config.languages, {
					prompt = "Select commit language:",
					format_item = function(item)
						return item
					end,
				}, function(language)
					if not language then
						return
					end
					state.language = language
					commit_with_claude(state)
				end)
			end, { desc = "Create a commit using Claude Code" })

			-- Create :ClaudeCodeIssue command
			vim.api.nvim_create_user_command("ClaudeCodeIssue", function()
				local state = {
					language = nil,
				}

				-- Language selection
				vim.ui.select(claude_config.languages, {
					prompt = "Select issue language:",
					format_item = function(item)
						return item
					end,
				}, function(language)
					if not language then
						return
					end
					state.language = language
					create_issue_with_claude(state)
				end)
			end, { desc = "Create a GitHub issue using Claude Code" })

			vim.keymap.set("n", "<leader>cP", ":ClaudeCodeCreatePR<CR>",
				{ desc = "Create a PR using Claude Code" })
			vim.keymap.set("n", "<leader>cM", ":ClaudeCodeCommit<CR>",
				{ desc = "Create a commit using Claude Code" })
			vim.keymap.set(
				"n",
				"<leader>cI",
				":ClaudeCodeIssue<CR>",
				{ desc = "Create a GitHub issue using Claude Code" }
			)
		end,
	}
end

return claudeCode
