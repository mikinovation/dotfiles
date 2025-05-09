local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field

vim.opt.rtp:prepend(lazypath)

-- Load clipboard configuration early
require("plugins.clipboard").config()

require("lazy").setup({
	require("plugins.avante").config(),
	require("plugins.comment").config(),
	require("plugins.copilot").config(),
	require("plugins.dropbar").config(),
	require("plugins.git-conflict").config(),
	require("plugins.gitsigns").config(),
	require("plugins.indent-blankline").config(),
	require("plugins.lazydev").config(),
	require("plugins.lualine").config(),
	require("plugins.markdown-preview").config(),
	require("plugins.mason").config(),
	require("plugins.nvim-tree").config(),
	require("plugins.neogit").config(),
	require("plugins.neotest").config(),
	require("plugins.none-ls").config(),
	require("plugins.nvim-autopairs").config(),
	require("plugins.nvim-bqf").config(),
	require("plugins.nvim-cmp").config(),
	require("plugins.nvim-context-vt").config(),
	require("plugins.nvim-dap").config(),
	require("plugins.nvim-notify").config(),
	require("plugins.nvim-treesitter-context").config(),
	require("plugins.nvim-treesitter").config(),
	require("plugins.nvim-ts-autotag").config(),
	require("plugins.nvim-ts-context-commentstring").config(),
	require("plugins.octo").config(),
	require("plugins.orgmode").config(),
	require("plugins.package-info").config(),
	require("plugins.pathtool").config(),
	require("plugins.telescope").config(),
	require("plugins.todo-comments").config(),
	require("plugins.toggleterm").config(),
	require("plugins.tokyonight").config(),
	require("plugins.tsc").config(),
	require("plugins.vim-argwrap").config(),
	require("plugins.vim-bundler").config(),
	require("plugins.vim-fugitive").config(),
	require("plugins.vim-matchup").config(),
	require("plugins.vim-rails").config(),
	require("plugins.vim-sleuth").config(),
	require("plugins.which-key").config(),
	require("plugins.yanky").config(),
	require("plugins.claude-code").config(),
}, {
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
