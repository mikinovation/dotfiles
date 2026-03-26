local telescopeFrecency = {}

function telescopeFrecency.config()
	return {
		"nvim-telescope/telescope-frecency.nvim",
		dependencies = {
			require("plugins.sqlite").config(),
		},
	}
end

return telescopeFrecency
