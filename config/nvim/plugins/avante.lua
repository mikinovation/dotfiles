local avante = {}

function avante.config()
	return {
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false,
		opts = {
			provider = "openrouter",
			vendors = {
				openrouter = {
					__inherited_from = "openai",
					disable_tools = true,
					endpoint = "https://openrouter.ai/api/v1",
					api_key_name = "OPENROUTER_API_KEY",
					model = "deepseek/deepseek-chat-v3-0324:free",
				},
			},
			behaviour = {
				auto_suggestions = false,
				auto_set_highlight_group = true,
				auto_set_keymaps = false,
				auto_apply_diff_after_generation = false,
				support_paste_from_clipboard = true,
				minimize_diff = true,
				enable_token_counting = true,
				enable_cursor_planning_mode = true,
			},
			mappings = {
				diff = {
					ours = "go",
					theirs = "gt",
					all_theirs = "ga",
					both = "gb",
					cursor = "gc",
					next = "]d",
					prev = "[d",
				},
				suggestion = {
					accept = "<M-CR>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
				jump = {
					next = "]]",
					prev = "[[",
				},
				submit = {
					normal = "<leader>as",
					insert = "<C-CR>",
				},
				cancel = {
					normal = { "<C-c>", "<Esc>" },
					insert = { "<C-c>" },
				},
				sidebar = {
					apply_all = "A",
					apply_cursor = "a",
					retry_user_request = "r",
					edit_user_request = "e",
					switch_windows = "<Tab>",
					reverse_switch_windows = "<S-Tab>",
					remove_file = "d",
					add_file = "@",
					close = { "<Esc>", "q" },
				},
			},
			windows = {
				position = "right",
				width = 40,
				input = {
					height = 10,
				},
				ask = {
					floating = true,
					start_insert = true,
					border = "rounded",
					focus_on_apply = "ours",
				},
			},
		},
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"echasnovski/mini.pick",
			"nvim-telescope/telescope.nvim",
			"hrsh7th/nvim-cmp",
			"ibhagwan/fzf-lua",
			"nvim-tree/nvim-web-devicons",
			"zbirenbaum/copilot.lua",
			{
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						use_absolute_path = true,
					},
				},
			},
			{
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		config = function()
			require("avante").setup()

			vim.keymap.set("n", "<leader>aa", ":AvanteAsk<CR>", { desc = "Ask AI about code" })
			vim.keymap.set("n", "<leader>at", ":AvanteToggle<CR>", { desc = "Toggle Avante sidebar" })
			vim.keymap.set("n", "<leader>ac", ":AvanteChat<CR>", { desc = "Start AI chat" })
			vim.keymap.set("n", "<leader>an", ":AvanteChatNew<CR>", { desc = "Start new AI chat" })
			vim.keymap.set("n", "<leader>ah", ":AvanteHistory<CR>", { desc = "Open chat history" })
			vim.keymap.set("n", "<leader>af", ":AvanteFocus<CR>", { desc = "Focus Avante window" })
			vim.keymap.set("n", "<leader>ar", ":AvanteRefresh<CR>", { desc = "Refresh Avante" })
			vim.keymap.set("n", "<leader>as", ":AvanteStop<CR>", { desc = "Stop AI request" })
			vim.keymap.set("n", "<leader>am", ":AvanteSwitchProvider<CR>", { desc = "Switch AI model" })
			vim.keymap.set("n", "<leader>ae", ":AvanteEdit<CR>", { desc = "Edit selected blocks" })
			vim.keymap.set("v", "<leader>aa", ":AvanteAsk<CR>", { desc = "Ask AI about selection" })
		end,
	}
end

return avante
