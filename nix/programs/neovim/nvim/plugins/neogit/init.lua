local neogit = {}

function neogit.config()
	return {
		"NeogitOrg/neogit",
		cmd = { "Neogit", "NeogitResetState" },
		dependencies = {
			require("plugins.plenary").config(),
		},
		config = true,
	}
end

return neogit
