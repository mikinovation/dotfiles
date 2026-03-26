local packageInfo = {}

function packageInfo.config()
	return {
		"vuki656/package-info.nvim",
		dependencies = {
			require("plugins.nui").config(),
		},
		config = function()
			require("package-info").setup()
			require("plugins.package-info.keymaps").setup()
		end,
	}
end

return packageInfo
