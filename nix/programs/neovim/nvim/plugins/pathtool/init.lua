local pathtool = {}

function pathtool.config()
	return {
		"mikinovation/pathtool.nvim",
		-- renovate: datasource=github-releases depName=mikinovation/pathtool.nvim
		-- commit=a4a97ffee7b105451c5925beb444847cdc468b
		-- Keep in sync with plugins/pathtool/keymaps.lua
		keys = {
			{ "<leader>pa", desc = "Copy absolute path" },
			{ "<leader>pr", desc = "Copy relative path" },
			{ "<leader>pp", desc = "Copy project-relative path" },
			{ "<leader>pf", desc = "Copy filename" },
			{ "<leader>pn", desc = "Copy filename without extension" },
			{ "<leader>pd", desc = "Copy directory path" },
			{ "<leader>pc", desc = "Convert path style" },
			{ "<leader>pu", desc = "Convert to file URL" },
			{ "<leader>po", desc = "Open path preview" },
		},
		config = function()
			require("pathtool").setup()
			require("plugins.pathtool.keymaps").setup()
		end,
	}
end

return pathtool
