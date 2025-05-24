local neogit = {}

function neogit.config()
	return {
		"NeogitOrg/neogit",
		commit = "333968f8222fda475d3e4545a9b15fe9912ca26a",
		dependencies = {
			require("plugins.plenary").config(),
			require("plugins.diffview").config(),
			require("plugins.telescope").config(),
		},
		config = true,
	}
end

return neogit
