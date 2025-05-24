local comment = {}

function comment.config()
	return {
		"numToStr/Comment.nvim",
		commit = "e30b7f2008e52442154b66f7c519bfd2f1e32acb",
		config = function()
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})
		end,
	}
end

return comment
