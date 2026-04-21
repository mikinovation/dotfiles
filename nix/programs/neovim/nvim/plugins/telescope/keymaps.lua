local M = {}

function M.setup()
	local builtin = require("telescope.builtin")
	local actions = require("plugins.telescope.actions")
	local map = vim.keymap.set

	-- Basic Telescope keymappings
	map("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
	map("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind Current [W]ord" })
	map("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
	map("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
	map("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
	map("n", "<leader>fB", builtin.buffers, { desc = "[F]ind [B]uffers" })

	-- Additional Telescope keymappings
	map("n", "<leader>f/", actions.current_buffer_fuzzy_find, { desc = "[F]ind [/] Fuzzily in Current Buffer" })
	map("n", "<leader>s/", actions.live_grep_open_files, { desc = "[S]earch [/] in Open Files" })
	map("n", "<leader>fn", actions.find_neovim_files, { desc = "[F]ind [N]eovim Files" })

	-- Extension keymappings
	map("n", "<leader>fb", ":Telescope file_browser<CR>", { desc = "[F]ile [B]rowser" })
	map("n", "<leader>fH", actions.file_browser_home, { desc = "[F]ile Browser - [H]ome Directory" })
	map("n", "<leader>fM", ":Telescope media_files<CR>", { desc = "[F]ind [M]edia Files" })
	map("n", "<leader>sf", ":Telescope frecency<CR>", { desc = "[S]earch [F]requent Files" })

	-- Git integration (git status/blame/branch covered by vim-fugitive)
	map("n", "<leader>gC", builtin.git_commits, { desc = "[G]it [C]ommits (Telescope)" })

	-- Custom function keymappings
	map("n", "<leader>fp", actions.project_files, { desc = "[F]ind [P]roject Files" })
	map("n", "<leader>sw", actions.grep_current_word, { desc = "[S]earch Current [W]ord" })
	map("v", "<leader>sw", actions.grep_visual_selection, { desc = "[S]earch Selected [W]ord" })
	map("n", "<leader>sr", actions.search_and_replace, { desc = "[S]earch and [R]eplace" })
	map("n", "<leader>fyg", actions.grep_yanked_text, { desc = "[F]ind [Y]anked Text (Grep)" })
	map("n", "<leader>fyf", actions.find_files_yanked, { desc = "[F]ind [Y]anked Text (Files)" })

	-- Current buffer directory search keymappings
	map("n", "<leader>fcf", actions.find_files_cwd, { desc = "[F]ind Files in [C]urrent Directory" })
	map("n", "<leader>fcg", actions.live_grep_cwd, { desc = "[F]ind by [G]rep in [C]urrent Directory" })
end

return M
