local tokyonight = {}

function tokyonight.config()
	return { -- You can easily change to a different colorscheme.
		"folke/tokyonight.nvim",
		commit = "057ef5d260c1931f1dffd0f052c685dcd14100a3",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		init = function()
			vim.cmd.colorscheme("tokyonight-night")
			vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
			vim.cmd("hi TelescopeNormal guibg=NONE ctermbg=NONE")
		end,
	}
end

return tokyonight
