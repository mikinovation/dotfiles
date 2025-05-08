local nvimTree = {}

function nvimTree.config()
	return {
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			require("plugins.nvim-web-devicons").config(),
		},
		opts = {
			view = {
				float = {
					enable = true,
					open_win_config = function()
						local columns = vim.o.columns
						local lines = vim.o.lines
						local width = math.min(columns - 4, 80)
						local height = math.min(lines - 4, 30)
						local left = math.floor((columns - width) / 2)
						local top = math.floor((lines - height) / 2 - 1)

						return {
							relative = "editor",
							border = "rounded",
							width = width,
							height = height,
							row = top,
							col = left,
						}
					end,
				},
				width = {
					min = 30,
					max = 40,
				},
			},
			filters = {
				dotfiles = false,
			},
			git = {
				enable = true,
				ignore = false,
			},
			actions = {
				open_file = {
					quit_on_open = false,
					window_picker = {
						enable = true,
					},
				},
			},
			renderer = {
				indent_markers = {
					enable = true,
				},
				icons = {
					git_placement = "before",
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
					},
				},
			},
		},
		config = function(_, opts)
			require("nvim-tree").setup(opts)

			-- Use nvim-tree for tree view and floating window
			vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
			vim.keymap.set(
				"n",
				"<leader>ef",
				"<cmd>lua require('nvim-tree.api').tree.toggle({path=nil, current_window=false, "
					.. "find_file=false, update_root=false, focus=true})<CR>",
				{ desc = "Toggle floating file explorer" }
			)
			vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeFindFile<CR>", { desc = "Reveal current file in tree" })
		end,
	}
end

return nvimTree