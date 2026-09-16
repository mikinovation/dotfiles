local M = {}

function M.name()
	return os.getenv("DOTFILES_PROFILE") or "full"
end

function M.is_full()
	return M.name() ~= "light"
end

return M
