local neogit = {}

function neogit.config()
	return {
		"NeogitOrg/neogit",
		dependencies = {
			require("plugins.plenary").config(),
			require("plugins.diffview").config(),
			require("plugins.telescope").config(),
		},
		config = true,
	}
end

return neogit
