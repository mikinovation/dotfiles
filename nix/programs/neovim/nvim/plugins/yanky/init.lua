local yanky = {}

function yanky.config()
	return {
		"gbprod/yanky.nvim",
		dependencies = {
			-- Required by ring.storage = "sqlite". Without it yanky silently
			-- falls back to an in-memory ring and the history is lost on exit.
			require("plugins.sqlite").config(),
		},
		config = function()
			require("yanky").setup({
				highlight = {
					timer = 200,
				},
				ring = {
					-- Persist the ring and share it between running instances.
					-- The default "shada" storage only writes on exit, so two
					-- open nvim instances never see each other's yanks.
					storage = "sqlite",
				},
				system_clipboard = {
					-- Must be explicit. yanky picks the register from &clipboard
					-- at setup time, but options.lua sets clipboard=unnamedplus
					-- inside vim.schedule(), which runs after lazy loads yanky.
					-- Without this yanky would watch "*" (primary selection) and
					-- never pick up what was copied on the Windows side.
					clipboard_register = "+",
				},
			})

			require("plugins.yanky.keymaps").setup()
		end,
	}
end

return yanky
