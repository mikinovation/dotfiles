local octo = {}

function octo.config()
	return {
		"pwntester/octo.nvim",
		commit = "974d2247b64535bedbbdbb7bec29dfa4e2395037",
		dependencies = {
			require("plugins.plenary").config(),
			require("plugins.telescope").config(),
			require("plugins.nvim-web-devicons").config(),
		},
		config = function()
			require("octo").setup({})
		end,
	}
end

return octo
