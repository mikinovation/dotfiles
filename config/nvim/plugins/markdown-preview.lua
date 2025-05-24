local markdownPreview = {}

function markdownPreview.config()
	return {
		"iamcco/markdown-preview.nvim",
		commit = "a923f5fc5ba36a3b17e289dc35dc17f66d0548ee",
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
