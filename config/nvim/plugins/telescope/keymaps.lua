local M = {}

-- Custom function to search within project (respects .gitignore)
local function project_files()
	local opts = {}
	local ok = pcall(require("telescope.builtin").git_files, opts)
	if not ok then
		require("telescope.builtin").find_files(opts)
	end
end

-- Grep search for word under cursor
local function grep_current_word()
	local word = vim.fn.expand("<cword>")
	require("telescope.builtin").grep_string({ search = word })
end

-- Search for text selected in visual mode
local function grep_visual_selection()
	local function get_visual_selection()
		local s_start = vim.fn.getpos("'<")
		local s_end = vim.fn.getpos("'>")
		local n_lines = math.abs(s_end[2] - s_start[2]) + 1
		local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
		lines[1] = string.sub(lines[1], s_start[3], -1)
		if n_lines == 1 then
			lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
		else
			lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
		end
		return table.concat(lines, " ")
	end

	local text = get_visual_selection()
	require("telescope.builtin").grep_string({ search = text })
end

-- Search and replace in files
local function search_and_replace()
	local word = vim.fn.expand("<cword>")
	local search_term = vim.fn.input("Search term: ", word)
	if search_term == "" then
		return
	end

	local replace_term = vim.fn.input("Replace with: ")
	if replace_term == "" then
		return
	end

	-- Display matching locations using Telescope
	require("telescope.builtin").grep_string({
		search = search_term,
		prompt_title = "Search: " .. search_term .. " → Replace: " .. replace_term,
		attach_mappings = function(_, map)
			map("i", "<CR>", function(prompt_bufnr)
				local confirmation = vim.fn.input("Execute? (y/n): ")
				if confirmation:lower() == "y" then
					vim.cmd("%s/" .. search_term .. "/" .. replace_term .. "/g")
					require("telescope.actions").close(prompt_bufnr)
				end
			end)
			return true
		end,
	})
end

-- Search for yanked text (from default register)
local function grep_yanked_text()
	local yanked = vim.fn.getreg('"')
	-- Remove newlines and extra whitespace for cleaner search
	yanked = yanked:gsub("[\n\r]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	if yanked == "" then
		vim.notify("No text in yank register", vim.log.levels.WARN)
		return
	end
	require("telescope.builtin").grep_string({ search = yanked })
end

-- Find files with yanked text as initial search
local function find_files_yanked()
	local yanked = vim.fn.getreg('"')
	yanked = yanked:gsub("[\n\r]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
	require("telescope.builtin").find_files({ default_text = yanked })
end

-- Find files relative to current buffer's directory
local function find_files_cwd()
	local current_file = vim.fn.expand("%:p")
	if current_file == "" then
		vim.notify("No current buffer", vim.log.levels.WARN)
		return
	end
	local cwd = vim.fn.fnamemodify(current_file, ":h")
	local cwd_display = vim.fn.fnamemodify(cwd, ":~")
	require("telescope.builtin").find_files({
		cwd = cwd,
		prompt_title = "Find Files (CWD: " .. cwd_display .. ")",
	})
end

-- Live grep relative to current buffer's directory
local function live_grep_cwd()
	local current_file = vim.fn.expand("%:p")
	if current_file == "" then
		vim.notify("No current buffer", vim.log.levels.WARN)
		return
	end
	local cwd = vim.fn.fnamemodify(current_file, ":h")
	local cwd_display = vim.fn.fnamemodify(cwd, ":~")
	require("telescope.builtin").live_grep({
		cwd = cwd,
		prompt_title = "Live Grep (CWD: " .. cwd_display .. ")",
	})
end

function M.setup()
	-- Basic Telescope keymappings
	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
	vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind Current [W]ord" })
	vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
	vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]ind [R]esume" })
	vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
	vim.keymap.set("n", "<leader>fB", builtin.buffers, { desc = "[F]ind [B]uffers" })

	-- Additional Telescope keymappings
	vim.keymap.set("n", "<leader>f/", function()
		builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
			winblend = 10,
			previewer = false,
		}))
	end, { desc = "[F]ind [/] Fuzzily in Current Buffer" })

	vim.keymap.set("n", "<leader>s/", function()
		builtin.live_grep({
			grep_open_files = true,
			prompt_title = "Live Grep in Open Files",
		})
	end, { desc = "[S]earch [/] in Open Files" })

	vim.keymap.set("n", "<leader>fn", function()
		builtin.find_files({ cwd = vim.fn.stdpath("config") })
	end, { desc = "[F]ind [N]eovim Files" })

	-- Extension keymappings
	vim.keymap.set("n", "<leader>fb", ":Telescope file_browser<CR>", { desc = "[F]ile [B]rowser" })

	-- Open home directory in file_browser
	vim.keymap.set("n", "<leader>fH", function()
		require("telescope").extensions.file_browser.file_browser({
			path = "~",
			cwd = "~",
			respect_gitignore = false,
			hidden = true,
			grouped = true,
			previewer = false,
			initial_mode = "normal",
			layout_config = { height = 40 },
		})
	end, { desc = "[F]ile Browser - [H]ome Directory" })

	vim.keymap.set("n", "<leader>fM", ":Telescope media_files<CR>", { desc = "[F]ind [M]edia Files" })
	vim.keymap.set("n", "<leader>sf", ":Telescope frecency<CR>", { desc = "[S]earch [F]requent Files" })

	-- Git integration (git status/blame/branch covered by vim-fugitive)
	vim.keymap.set("n", "<leader>gC", builtin.git_commits, { desc = "[G]it [C]ommits (Telescope)" })

	-- Custom function keymappings
	vim.keymap.set("n", "<leader>fp", project_files, { desc = "[F]ind [P]roject Files" })
	vim.keymap.set("n", "<leader>sw", grep_current_word, { desc = "[S]earch Current [W]ord" })
	vim.keymap.set("v", "<leader>sw", grep_visual_selection, { desc = "[S]earch Selected [W]ord" })
	vim.keymap.set("n", "<leader>sr", search_and_replace, { desc = "[S]earch and [R]eplace" })
	vim.keymap.set("n", "<leader>fyg", grep_yanked_text, { desc = "[F]ind [Y]anked Text (Grep)" })
	vim.keymap.set("n", "<leader>fyf", find_files_yanked, { desc = "[F]ind [Y]anked Text (Files)" })

	-- Current buffer directory search keymappings
	vim.keymap.set("n", "<leader>fcf", find_files_cwd, { desc = "[F]ind Files in [C]urrent Directory" })
	vim.keymap.set("n", "<leader>fcg", live_grep_cwd, { desc = "[F]ind by [G]rep in [C]urrent Directory" })
end

return M
