local quickScope = {}

function quickScope.config()
	return {
		"unblevable/quick-scope",
		config = function()
			-- Set highlight colors that match with tokyonight theme
			vim.cmd([[
				highlight QuickScopePrimary guifg=#ff9e64 gui=underline ctermfg=214 cterm=underline
				highlight QuickScopeSecondary guifg=#7dcfff gui=underline ctermfg=81 cterm=underline
			]])

			-- Set trigger keys
			vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }

			-- Enabling on specified filetypes (enable on most filetypes except where it might be distracting)
			vim.g.qs_buftype_blacklist = { "terminal", "nofile" }
			vim.g.qs_filetype_blacklist = { "help", "dashboard", "packer", "NvimTree", "Trouble", "TelescopePrompt" }
		end,
	}
end

return quickScope
