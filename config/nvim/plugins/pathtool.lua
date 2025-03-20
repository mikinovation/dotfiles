local pathtool = {}

function pathtool.config()
	return {
		"mikinovation/pathtool.nvim",
		config = function()
			require("pathtool").setup()
		end,
	}
end

return pathtool
