local git_operations = {}

function git_operations.get_git_root()
	local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
	if not handle then
		return nil
	end
	local git_root = handle:read("*a"):gsub("%s+$", "")
	handle:close()
	if git_root == "" then
		return nil
	end
	return git_root
end

function git_operations.check_template_exists(template_path)
	local git_root = git_operations.get_git_root()
	if not git_root then
		return false
	end

	local stat = vim.loop.fs_stat(git_root .. template_path)
	return stat ~= nil
end

function git_operations.find_pr_template()
	local git_root = git_operations.get_git_root()
	if not git_root then
		return nil
	end

	local possible_paths = {
		"/.github/pull_request_template.md",
		"/.github/PULL_REQUEST_TEMPLATE.md",
	}

	for _, path in ipairs(possible_paths) do
		local stat = vim.loop.fs_stat(git_root .. path)
		if stat ~= nil then
			return path
		end
	end

	return nil
end

function git_operations.get_local_branches()
	local handle = io.popen("git branch 2>/dev/null | sed 's/^[[:space:]]*\\*\\?[[:space:]]*//'")
	if not handle then
		return {}
	end

	local branches = {}
	for line in handle:lines() do
		if line ~= "" then
			table.insert(branches, line)
		end
	end
	handle:close()

	return branches
end

function git_operations.get_relative_path(file_path)
	local git_root = git_operations.get_git_root()
	if not git_root then
		return file_path
	end

	local relative_path = file_path:gsub("^" .. vim.pesc(git_root) .. "/", "")
	return relative_path
end

return git_operations
