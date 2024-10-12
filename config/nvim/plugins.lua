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
	"tpope/vim-sleuth",
	require("plugins.gitsigns").config(),
	require("plugins.which-key").config(),
	require("plugins.telescope").config(),
	require("plugins.neo-tree").config(),
	require("plugins.neogit").config(),
	require("plugins.lazydev").config(),
	require("plugins.luvit-meta").config(),
	require("plugins.nvim-lspconfig").config(),
	require("plugins.conform").config(),
	require("plugins.nvim-cmp").config(),
	require("plugins.tokyonight").config(),
	require("plugins.todo-comments").config(),
	require("plugins.mini").config(),
	require("plugins.nvim-treesitter").config(),
	require("plugins.copilot-chat").config(),
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
