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
			require("plugins.markdown-preview.keymaps").setup()
		end,
	}
end

return markdownPreview
