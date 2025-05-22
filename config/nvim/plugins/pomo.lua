local pomo = {}

function pomo.config()
	return {
		"epwalsh/pomo.nvim",
		version = "*",
		lazy = false,
		dependencies = {
			"rcarriga/nvim-notify",
		},
		opts = {
			sessions = {
				pomodoro = {
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Long Break", duration = "15m" },
				},
			},
			notifiers = {
				{
					init = function(timer)
						local win_id = nil
						local buf_id = nil

						local function create_floating_window()
							buf_id = vim.api.nvim_create_buf(false, true)
							local width = 60
							local height = 8
							local opts = {
								relative = "editor",
								width = width,
								height = height,
								col = (vim.o.columns - width) / 2,
								row = (vim.o.lines - height) / 2,
								style = "minimal",
								border = "double",
								title = "🍅 ポモドーロタイマー",
								title_pos = "center",
							}
							win_id = vim.api.nvim_open_win(buf_id, false, opts)
							vim.api.nvim_win_set_option(win_id, "winhl", "Normal:ErrorMsg,FloatBorder:WarningMsg")
						end

						local function update_window(time_left)
							if not win_id or not vim.api.nvim_win_is_valid(win_id) then
								create_floating_window()
							end

							local minutes = math.floor(time_left / 60)
							local seconds = time_left % 60
							local time_str = string.format("%02d:%02d", minutes, seconds)

							local lines = {
								"",
								string.format("        %s: %s", timer.name, time_str),
								"",
								"    📋 メモやチケットのステータスを更新しろ！",
								"",
								"    ⚡ 進捗を記録して次のステップを計画しろ！",
								"",
							}

							if timer.name == "Work" and time_left <= 300 then
								table.insert(lines, 3, "    🚨 残り5分！タスク更新の準備をしろ！")
							end

							vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
						end

						local function close_window()
							if win_id and vim.api.nvim_win_is_valid(win_id) then
								vim.api.nvim_win_close(win_id, true)
								win_id = nil
							end
							if buf_id and vim.api.nvim_buf_is_valid(buf_id) then
								vim.api.nvim_buf_delete(buf_id, { force = true })
								buf_id = nil
							end
						end

						return {
							start = function()
								create_floating_window()
							end,
							tick = function(time_left)
								update_window(time_left)
							end,
							done = function()
								close_window()

								-- Show completion message
								local completion_buf = vim.api.nvim_create_buf(false, true)
								local completion_lines = {}

								if timer.name == "Work" then
									completion_lines = {
										"",
										"    🎉 作業セッション完了！",
										"",
										"    📝 今すぐやること：",
										"    • メモやチケットのステータスを更新",
										"    • 次のタスクを計画",
										"    • 進捗を記録",
										"",
										"    Press any key to close...",
									}
								else
									completion_lines = {
										"",
										"    ⏰ 休憩終了！",
										"",
										"    🔥 次の作業に集中しましょう！",
										"",
										"    Press any key to close...",
									}
								end

								local completion_opts = {
									relative = "editor",
									width = 50,
									height = #completion_lines + 2,
									col = (vim.o.columns - 50) / 2,
									row = (vim.o.lines - #completion_lines - 2) / 2,
									style = "minimal",
									border = "double",
									title = timer.name == "Work" and "作業完了" or "休憩終了",
									title_pos = "center",
								}

								local completion_win = vim.api.nvim_open_win(completion_buf, true, completion_opts)
								vim.api.nvim_win_set_option(
									completion_win,
									"winhl",
									"Normal:DiffAdd,FloatBorder:DiffText"
								)
								vim.api.nvim_buf_set_lines(completion_buf, 0, -1, false, completion_lines)

								vim.api.nvim_buf_set_keymap(
									completion_buf,
									"n",
									"<CR>",
									"<cmd>close<CR>",
									{ noremap = true, silent = true }
								)
								vim.api.nvim_buf_set_keymap(
									completion_buf,
									"n",
									"<Esc>",
									"<cmd>close<CR>",
									{ noremap = true, silent = true }
								)
								vim.api.nvim_buf_set_keymap(
									completion_buf,
									"n",
									"q",
									"<cmd>close<CR>",
									{ noremap = true, silent = true }
								)
							end,
						}
					end,
				},
			},
		},
		config = function(_, opts)
			require("pomo").setup(opts)

			vim.keymap.set("n", "<leader>ps", ":TimerSession pomodoro<CR>", { desc = "Start pomodoro session" })
			vim.keymap.set("n", "<leader>pt", ":TimerStop<CR>", { desc = "Stop current timer" })

			-- Ask to start pomodoro session on startup
			vim.schedule(function()
				local choice = vim.fn.confirm("Start pomodoro session?", "&Yes\n&No", 1)
				if choice == 1 then
					vim.cmd("TimerSession pomodoro")
				end
			end)
		end,
	}
end

return pomo
