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
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
					{ name = "Work", duration = "25m" },
					{ name = "Short Break", duration = "5m" },
				},
			},
		},
		config = function(_, opts)
			-- Custom floating window notifier class
			local FloatingNotifier = {}
			FloatingNotifier.__index = FloatingNotifier

			function FloatingNotifier.new(timer, notifier_opts)
				local self = setmetatable({}, FloatingNotifier)
				self.timer = timer
				self.opts = notifier_opts or {}
				self.win_id = nil
				self.buf_id = nil
				return self
			end

			function FloatingNotifier:start()
				self:create_window()
				self:update_content(self.timer.time_limit)
			end

			function FloatingNotifier:tick(time_left)
				if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
					self:update_content(time_left)
				end
			end

			function FloatingNotifier:done()
				self:show_completion_dialog()
			end

			function FloatingNotifier:stop()
				self:cleanup()
			end

			function FloatingNotifier:create_window()
				self:cleanup()

				local width = 60
				local height = 8
				self.buf_id = vim.api.nvim_create_buf(false, true)

				local ui = vim.api.nvim_list_uis()[1]
				local col = math.floor((ui.width - width) / 2)
				local row = math.floor((ui.height - height) / 2)

				local win_opts = {
					relative = "editor",
					width = width,
					height = height,
					col = col,
					row = row,
					style = "minimal",
					border = "rounded",
				}

				self.win_id = vim.api.nvim_open_win(self.buf_id, false, win_opts)

				-- Set buffer options
				vim.api.nvim_buf_set_option(self.buf_id, "modifiable", false)
				vim.api.nvim_buf_set_option(self.buf_id, "buftype", "nofile")

				-- Set keymaps for closing
				local close_keys = { "<CR>", "<Esc>", "q" }
				for _, key in ipairs(close_keys) do
					vim.api.nvim_buf_set_keymap(self.buf_id, "n", key, "", {
						callback = function()
							self:cleanup()
						end,
						noremap = true,
						silent = true,
					})
				end
			end

			function FloatingNotifier:update_content(time_left)
				if not self.buf_id or not vim.api.nvim_buf_is_valid(self.buf_id) then
					return
				end

				local time_str = FloatingNotifier.format_time(time_left)
				local is_break = self.timer.name:match("Break")

				local lines = {
					"",
					"  🍅 " .. self.timer.name .. ": " .. time_str,
					"",
				}

				if is_break then
					-- During breaks, remind to update task status
					table.insert(lines, "  メモやチケットのステータスを更新しろ！")
					table.insert(lines, "")
				else
					-- During work sessions, encourage focus
					table.insert(lines, "  集中して作業を続けましょう！")
					table.insert(lines, "")
				end

				vim.api.nvim_buf_set_option(self.buf_id, "modifiable", true)
				vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, lines)
				vim.api.nvim_buf_set_option(self.buf_id, "modifiable", false)

				-- Apply highlighting
				if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
					vim.api.nvim_win_set_option(self.win_id, "winhl", "Normal:WarningMsg")
				end
			end

			function FloatingNotifier:show_completion_dialog()
				self:create_window()

				local lines = {
					"",
					"  ✅ " .. self.timer.name .. " 完了！",
					"",
				}

				vim.api.nvim_buf_set_option(self.buf_id, "modifiable", true)
				vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, false, lines)
				vim.api.nvim_buf_set_option(self.buf_id, "modifiable", false)

				if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
					vim.api.nvim_win_set_option(self.win_id, "winhl", "Normal:WarningMsg")
				end

				-- Auto-close after 2 seconds
				vim.defer_fn(function()
					self:cleanup()
				end, 2000)
			end

			function FloatingNotifier.format_time(seconds)
				local mins = math.floor(seconds / 60)
				local secs = seconds % 60
				return string.format("%02d:%02d", mins, secs)
			end

			function FloatingNotifier:cleanup()
				if self.win_id and vim.api.nvim_win_is_valid(self.win_id) then
					vim.api.nvim_win_close(self.win_id, true)
				end
				if self.buf_id and vim.api.nvim_buf_is_valid(self.buf_id) then
					vim.api.nvim_buf_delete(self.buf_id, { force = true })
				end
				self.win_id = nil
				self.buf_id = nil
			end

			-- Configure notifiers
			opts.notifiers = {
				{
					init = function(timer)
						return FloatingNotifier.new(timer, {})
					end,
				},
			}
			opts.update_interval = 500 -- Update every 500ms for smooth countdown

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
