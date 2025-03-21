local tokyonight = {}

function tokyonight.config()
	return { -- You can easily change to a different colorscheme.
		"folke/tokyonight.nvim",
		priority = 1000, -- Make sure to load this before all the other start plugins.
		init = function()
			vim.cmd.colorscheme("tokyonight-night")
			vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
			vim.cmd("hi TelescopeNormal guibg=NONE ctermbg=NONE")
		end,
	}
end

return tokyonight
