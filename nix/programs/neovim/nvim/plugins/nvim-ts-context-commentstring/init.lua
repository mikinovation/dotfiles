local nvimTsContextCommentstring = {}

function nvimTsContextCommentstring.config()
	return {
		"JoosepAlviste/nvim-ts-context-commentstring",
		-- Loaded on demand as a dependency of Comment.nvim
		lazy = true,
		config = function()
			require("ts_context_commentstring").setup({
				enable_autocmd = false,
			})
		end,
	}
end

return nvimTsContextCommentstring
