local todoComments = {}

function todoComments.config()
	return { -- You can easily change to a different colorscheme.
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	}
end

return todoComments
