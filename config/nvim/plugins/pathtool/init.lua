local pathtool = {}

function pathtool.config()
	return {
		"mikinovation/pathtool.nvim",
		-- renovate: datasource=github-releases depName=mikinovation/pathtool.nvim
		-- commit=a4a97ffee7b105451c5925beb444847cdc468b
		config = function()
			require("pathtool").setup()
			require("plugins.pathtool.keymaps").setup()
		end,
	}
end

return pathtool
