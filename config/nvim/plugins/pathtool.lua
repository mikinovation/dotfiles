local pathtool = {}

function pathtool.config()
	return {
		"mikinovation/pathtool.nvim",
		-- renovate: datasource=github-releases depName=mikinovation/pathtool.nvim
	-- commit=a4a97ffee7b105451c5925beb444847cdc468b
		commit = "94a4a97ffee7b105451c5925beb444847cdc468b",
		config = function()
			require("pathtool").setup()

			vim.keymap.set("n", "<leader>pa", ":PathCopyAbsolute<CR>", { desc = "Copy absolute path", silent = true })
			vim.keymap.set("n", "<leader>pr", ":PathCopyRelative<CR>", { desc = "Copy relative path", silent = true })
			vim.keymap.set(
				"n",
				"<leader>pp",
				":PathCopyProject<CR>",
				{ desc = "Copy project-relative path", silent = true }
			)
			vim.keymap.set("n", "<leader>pf", ":PathCopyFilename<CR>", { desc = "Copy filename", silent = true })
			vim.keymap.set(
				"n",
				"<leader>pn",
				":PathCopyFilenameNoExt<CR>",
				{ desc = "Copy filename without extension", silent = true }
			)
			vim.keymap.set("n", "<leader>pd", ":PathCopyDirname<CR>", { desc = "Copy directory path", silent = true })
			vim.keymap.set("n", "<leader>pc", ":PathConvertStyle<CR>", { desc = "Convert path style", silent = true })
			vim.keymap.set("n", "<leader>pu", ":PathToUrl<CR>", { desc = "Convert to file URL", silent = true })
			vim.keymap.set("n", "<leader>po", ":PathPreview<CR>", { desc = "Open path preview", silent = true })
		end,
	}
end

return pathtool
