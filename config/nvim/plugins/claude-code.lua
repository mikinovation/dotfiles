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
					split_ratio = 0.5, -- Percentage of screen for the terminal window (height for horizontal, width for vertical splits)
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

			-- PR作成のためのカスタム設定
			local pr_config = {
				languages = { "ja", "en" },
				draft_options = { "draft", "open" },
				ticket_required = false,
			}

			-- PR作成のカスタムコマンド
			vim.api.nvim_create_user_command("ClaudeCodeCreatePR", function()
				local state = {
					language = nil,
					draft_mode = nil,
					ticket = nil,
				}

				-- 言語選択
				vim.ui.select(pr_config.languages, {
					prompt = "PRの言語を選択してください:",
					format_item = function(item)
						return item
					end,
				}, function(language)
					if not language then
						return
					end
					state.language = language

					-- ドラフト/オープン選択
					vim.ui.select(pr_config.draft_options, {
						prompt = "PRの状態を選択してください:",
						format_item = function(item)
							return item
						end,
					}, function(draft_mode)
						if not draft_mode then
							return
						end
						state.draft_mode = draft_mode

						-- チケットリンク入力（任意）
						if pr_config.ticket_required then
							vim.ui.input({
								prompt = "チケットリンクを入力してください:",
							}, function(ticket)
								state.ticket = ticket or ""
								create_pr_with_claude(state)
							end)
						else
							vim.ui.input({
								prompt = "チケットリンクを入力してください（任意）:",
							}, function(ticket)
								state.ticket = ticket or ""
								create_pr_with_claude(state)
							end)
						end
					end)
				end)
			end, { desc = "Create a PR using Claude Code" })

			function create_pr_with_claude(state)
				local cmd = "claude"

				-- PRの命令文を作成
				local instruction_parts = {
					"これからclaude codeで",
					"- " .. state.language .. "語でプルリクを出す",
					"- " .. (state.draft_mode == "draft" and "下書き" or "オープン") .. "にする",
				}

				-- チケット情報があれば追加
				if state.ticket and state.ticket ~= "" then
					table.insert(instruction_parts, "- チケット: " .. state.ticket)
				end

				table.insert(
					instruction_parts,
					"を入力してからclaude codeにプルリクを作成するよう指示します"
				)

				-- 命令文を一つの文字列に結合
				local instruction_text = table.concat(instruction_parts, "\n")

				-- Claude Codeを起動
				vim.cmd("ClaudeCode")

				-- 少し遅延を入れてから命令を送信（ウィンドウがロードされるのを待つ）
				vim.defer_fn(function()
					-- ターミナルバッファのジョブIDを取得
					local bufnr = require("claude-code").claude_code.bufnr
					if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
						local chan_id = vim.api.nvim_buf_get_var(bufnr, "terminal_job_id")
						if chan_id then
							-- ターミナルにテキストを送信
							vim.api.nvim_chan_send(chan_id, instruction_text)
						end
					end
				end, 2000) -- 遅延時間を1秒に短縮
			end

			-- キーマップを追加
			vim.keymap.set("n", "<leader>cP", ":ClaudeCodeCreatePR<CR>", { desc = "Create a PR using Claude Code" })
		end,
	}
end

return claudeCode
