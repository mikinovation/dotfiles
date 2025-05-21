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
