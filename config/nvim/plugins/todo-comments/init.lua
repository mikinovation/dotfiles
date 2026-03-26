local todoComments = {}

function todoComments.config()
	return { -- You can easily change to a different colorscheme.
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = {
			require("plugins.plenary").config(),
		},
		opts = { signs = false },
	}
end

return todoComments
