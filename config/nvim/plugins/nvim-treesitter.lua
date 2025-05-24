local nvimTreesitter = {}

function nvimTreesitter.config()
	return { -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		commit = "3b308861a8d7d7bfbe9be51d52e54dcfd9fe3d38",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs", -- Sets main module to use for opts
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
	}
end

return nvimTreesitter
