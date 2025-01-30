local copilotChat = {}

function copilotChat.config()
	return {
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			{ "github/copilot.vim", branch = "release" },
			{ "nvim-lua/plenary.nvim", branch = "master" },
		},
		opts = {},
	}
end

return copilotChat
