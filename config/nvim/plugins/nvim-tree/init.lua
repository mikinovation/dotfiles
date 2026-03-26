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
			require("plugins.nvim-tree.keymaps").setup()
		end,
	}
end

return nvimTree
