local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end ---@diagnostic disable-next-line: undefined-field

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	require("plugins.nvim-notify").config(),
	require("plugins.gitsigns").config(),
	require("plugins.which-key").config(),
	require("plugins.telescope").config(),
	require("plugins.toggleterm").config(),
	require("plugins.neo-tree").config(),
	require("plugins.neogit").config(),
	require("plugins.lazydev").config(),
	require("plugins.luvit-meta").config(),
	require("plugins.none-ls").config(),
	require("plugins.nvim-cmp").config(),
	require("plugins.nvim-lspconfig").config(),
	require("plugins.vim-matchup").config(),
	require("plugins.nvim-autopairs").config(),
	require("plugins.nvim-ts-autotag").config(),
	require("plugins.tokyonight").config(),
	require("plugins.todo-comments").config(),
	require("plugins.lualine").config(),
	require("plugins.nvim-treesitter").config(),
	require("plugins.copilot-chat").config(),
	require("plugins.nvim-dap").config(),
	require("plugins.neotest").config(),
	require("plugins.git-conflict").config(),
	require("plugins.tsc").config(),
	require("plugins.nvim-bqf").config(),
	require("plugins.yanky").config(),
	require("plugins.indent-blankline").config(),
	"tpope/vim-sleuth",
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
