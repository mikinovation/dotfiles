local telescopeFzfNative = {}

function telescopeFzfNative.config()
	return {
		"nvim-telescope/telescope-fzf-native.nvim",
		commit = "1f08ed60cafc8f6168b72b80be2b2ea149813e55",
		build = "make",
		cond = function()
			return vim.fn.executable("make") == 1
		end,
	}
end

return telescopeFzfNative
