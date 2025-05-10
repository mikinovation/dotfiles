local nvimDbee = {}

function nvimDbee.config()
	return {
		"kndndrj/nvim-dbee",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			require("dbee").install()
		end,
		config = function()
			require("dbee").setup({
				sources = {
					require("dbee.sources").FileSource:new(vim.fn.stdpath("cache") .. "/dbee/persistence.json"),
				},
			})

			vim.keymap.set("n", "<leader>db", "<cmd>Dbee toggle<CR>", { desc = "Toggle DBee" })
		end,
	}
end

return nvimDbee
