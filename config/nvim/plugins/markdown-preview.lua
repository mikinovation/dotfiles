local markdownPreview = {}

function markdownPreview.config()
	return {
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
		config = function()
			-- Markdown Preview keymap
			vim.keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", { desc = "[M]arkdown [P]review" })
		end,
	}
end

return markdownPreview
