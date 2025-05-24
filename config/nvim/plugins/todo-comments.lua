local todoComments = {}

function todoComments.config()
	return { -- You can easily change to a different colorscheme.
		"folke/todo-comments.nvim",
		commit = "304a8d204ee787d2544d8bc23cd38d2f929e7cc5",
		event = "VimEnter",
		dependencies = {
			require("plugins.plenary").config(),
		},
		opts = { signs = false },
	}
end

return todoComments
