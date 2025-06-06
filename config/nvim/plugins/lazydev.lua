local lazydev = {}

function lazydev.config()
	return {
		"folke/lazydev.nvim",
		commit = "2367a6c0a01eb9edb0464731cc0fb61ed9ab9d2c",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	}
end

return lazydev
