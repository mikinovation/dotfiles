local gitsign = {}

function gitsign.config()
	return {
		"lewis6991/gitsigns.nvim",
		commit = "1796c7cedfe7e5dd20096c5d7b8b753d8f8d22eb",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	}
end

return gitsign
