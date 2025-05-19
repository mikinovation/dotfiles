local claudeCode = {}

function claudeCode.config()
	return {
		"greggh/claude-code.nvim",
		dependencies = {
			require("plugins.plenary").config(),
		},
		config = function()
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

			local function check_template_exists(template_path)
				local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
				if not handle then
					return false
				end
				local git_root = handle:read("*a"):gsub("%s+$", "")
				handle:close()
				if git_root == "" then
					return false
				end

				local stat = vim.loop.fs_stat(git_root .. template_path)
				return stat ~= nil
			end

			local function send_to_claude(instruction_text)
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
				end, window_exists and 100 or 1000)
			end

			local function build_commit_instruction(state)
				local parts = {
					"I'm going to create a git commit. Please follow these instructions:",
					"- Create a commit in " .. state.language .. " language",
					"- Follow conventional commits format (e.g., `feat:`, `fix:`, `chore:`)",
					"- Use git status to see what files have changed",
					"- Use git diff to understand the changes",
					"- Create the commit using git commit -m with an appropriate message",
					"- Do NOT add any AI attribution lines to the commit message",
				}
				return table.concat(parts, "\n")
			end

			local function build_issue_instruction(state)
				local parts = {
					"I'm going to create a GitHub issue. I will use gh command. Please follow these instructions:",
					"- Create an issue in " .. state.language .. " language",
					"- Use gh issue create command to create the issue",
				}

				if check_template_exists("/.github/ISSUE_TEMPLATE") then
					table.insert(
						parts,
						"- Please check if there are templates in .github/ISSUE_TEMPLATE and use the appropriate template"
					)
				end

				return table.concat(parts, "\n")
			end

			local function build_pr_instruction(state)
				local parts = {
					"I'm going to create a pull request. I will use gh command. Please follow these instructions:",
					"- Create a PR in " .. state.language .. " language",
					"- Set PR status to " .. (state.draft_mode == "draft" and "draft" or "open"),
					"- Assign myself to the PR",
				}

				if state.base_branch and state.base_branch ~= "" then
					table.insert(parts, "- Use '" .. state.base_branch .. "' as the base branch for the PR")
					table.insert(parts, "- Before pushing, rebase from origin/" .. state.base_branch)
				end

				if state.ticket and state.ticket ~= "" then
					table.insert(parts, "- With ticket reference: " .. state.ticket)
				end

				if check_template_exists("/.github/PULL_REQUEST_TEMPLATE.md") then
					table.insert(parts, "- Please follow the template format in .github/PULL_REQUEST_TEMPLATE.md")
				else
					table.insert(
						parts,
						"- Please check if .github/PULL_REQUEST_TEMPLATE.md exists and follow that template format if found"
					)
				end

				return table.concat(parts, "\n")
			end

			local function run_commit_with_claude(state)
				send_to_claude(build_commit_instruction(state))
			end

			local function run_issue_with_claude(state)
				send_to_claude(build_issue_instruction(state))
			end

			local function run_pr_with_claude(state)
				send_to_claude(build_pr_instruction(state))
			end

			local function build_push_instruction(state)
				local parts = {
					"I'm going to push changes. Please follow these instructions:",
					"- Create a push in " .. state.language .. " language",
					"- First, check if a pull request already exists for the current branch",
					"- If a PR exists, use git merge to update from the base branch before pushing",
					"- If no PR exists, use git rebase from the default branch (usually main or master) before pushing",
					"- After the merge/rebase is successful, push the changes to origin",
				}
				return table.concat(parts, "\n")
			end

			local function run_push_with_claude(state)
				send_to_claude(build_push_instruction(state))
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
				-- Get remote branches from origin
				local handle = io.popen(
					"git branch -r 2>/dev/null | grep -v 'HEAD' | sed 's/^[[:space:]]*//' | sed 's|^origin/||'"
				)
				if not handle then
					return {}
				end

				local branches = {}
				for line in handle:lines() do
					table.insert(branches, line)
				end
				handle:close()

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
				select_language(run_push_with_claude)
			end, { desc = "Push changes using Claude Code" })

			-- Keymap
			vim.keymap.set("n", "<leader>cP", ":ClaudeCodeCreatePR<CR>", { desc = "Create a PR using Claude Code" })
			vim.keymap.set("n", "<leader>cM", ":ClaudeCodeCommit<CR>", { desc = "Create a commit using Claude Code" })
			vim.keymap.set(
				"n",
				"<leader>cI",
				":ClaudeCodeIssue<CR>",
				{ desc = "Create a GitHub issue using Claude Code" }
			)
			vim.keymap.set("n", "<leader>cZ", ":ClaudeCodePush<CR>", { desc = "Push changes using Claude Code" })
		end,
	}
end

return claudeCode
