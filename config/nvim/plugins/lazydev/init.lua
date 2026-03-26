local lazydev = {}

function lazydev.config()
	return {
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	}
end

return lazydev
