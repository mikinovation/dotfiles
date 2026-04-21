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
					},
					file_browser = {
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
							{ "~/ghq", max_depth = 5 },
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
							["project"] = "~/ghq",
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

			require("plugins.telescope.keymaps").setup()
		end,
	}
end

return telescope
