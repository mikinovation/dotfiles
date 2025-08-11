local nvimTsContextCommentstring = {}

function nvimTsContextCommentstring.config()
	return {
		"JoosepAlviste/nvim-ts-context-commentstring",
		config = function()
			require("ts_context_commentstring").setup({
				enable_autocmd = false,
			})
		end,
	}
end

return nvimTsContextCommentstring
