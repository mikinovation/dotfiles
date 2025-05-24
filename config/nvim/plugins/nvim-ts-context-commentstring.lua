local nvimTsContextCommentstring = {}

function nvimTsContextCommentstring.config()
	return {
		"JoosepAlviste/nvim-ts-context-commentstring",
		commit = "1b212c2eee76d787bbea6aa5e92a2b534e7b4f8f",
		config = function()
			require("ts_context_commentstring").setup({
				enable_autocmd = false,
			})
		end,
	}
end

return nvimTsContextCommentstring
