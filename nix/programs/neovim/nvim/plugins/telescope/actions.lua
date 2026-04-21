-- plugins/telescope/actions.lua
-- Custom telescope-related action functions invoked by keymaps.

local M = {}

--- Find files within the current project, preferring git-tracked files.
function M.project_files()
	local opts = {}
	local ok = pcall(require("telescope.builtin").git_files, opts)
	if not ok then
		require("telescope.builtin").find_files(opts)
	end
end

--- Grep for the word under the cursor.
function M.grep_current_word()
	local word = vim.fn.expand("<cword>")
	require("telescope.builtin").grep_string({ search = word })
end

--- Read the current visual selection as a single concatenated string.
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

--- Grep for the text currently selected in visual mode.
function M.grep_visual_selection()
	local text = get_visual_selection()
	require("telescope.builtin").grep_string({ search = text })
end

--- Interactive search-and-replace flow backed by telescope grep.
function M.search_and_replace()
	local word = vim.fn.expand("<cword>")
	local search_term = vim.fn.input("Search term: ", word)
	if search_term == "" then
		return
	end

	local replace_term = vim.fn.input("Replace with: ")
	if replace_term == "" then
		return
	end

	require("telescope.builtin").grep_string({
		search = search_term,
		prompt_title = "Search: " .. search_term .. " → Replace: " .. replace_term,
		attach_mappings = function(_, map)
			map("i", "<CR>", function(prompt_bufnr)
				local confirmation = vim.fn.input("Execute? (y/n): ")
				if confirmation:lower() == "y" then
					local escaped_search = vim.fn.escape(search_term, "/\\")
					local escaped_replace = vim.fn.escape(replace_term, "/\\&")
					-- \V (very nomagic) makes the pattern literal: only the delimiter
					-- and backslash remain special, so characters like . * [ ] ^ $
					-- in the user's input match themselves.
					vim.cmd("%s/\\V" .. escaped_search .. "/" .. escaped_replace .. "/g")
					require("telescope.actions").close(prompt_bufnr)
				end
			end)
			return true
		end,
	})
end

--- Strip noise from the contents of the unnamed yank register.
local function get_normalized_yank()
	local yanked = vim.fn.getreg('"')
	return yanked:gsub("[\n\r]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

--- Grep for the contents of the unnamed yank register.
function M.grep_yanked_text()
	local yanked = get_normalized_yank()
	if yanked == "" then
		vim.notify("No text in yank register", vim.log.levels.WARN)
		return
	end
	require("telescope.builtin").grep_string({ search = yanked })
end

--- Find files using the unnamed yank register as the initial search query.
function M.find_files_yanked()
	local yanked = get_normalized_yank()
	require("telescope.builtin").find_files({ default_text = yanked })
end

--- Find files relative to the current buffer's directory.
function M.find_files_cwd()
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

--- Live grep relative to the current buffer's directory.
function M.live_grep_cwd()
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

--- Fuzzy-find within the current buffer using a dropdown layout.
function M.current_buffer_fuzzy_find()
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end

--- Live grep across all currently open buffers.
function M.live_grep_open_files()
	require("telescope.builtin").live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end

--- Find files inside the user's Neovim config directory.
function M.find_neovim_files()
	require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end

--- Open the file_browser extension at the user's home directory.
function M.file_browser_home()
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
end

return M
