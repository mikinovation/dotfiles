local telescopeFrecency = {}

function telescopeFrecency.config()
	return {
		"nvim-telescope/telescope-frecency.nvim",
		commit = "4d2f5854d3a161b355c4949059e6cd1087fd1d4a",
		dependencies = {
			require("plugins.sqlite").config(),
		},
	}
end

return telescopeFrecency
