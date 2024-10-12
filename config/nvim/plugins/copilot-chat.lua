local copilotChat = {}

function copilotChat.config()
	return {
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "canary",
		dependencies = {
			{ "github/copilot.vim" },
			{ "nvim-lua/plenary.nvim" },
		},
		opts = {},
	}
end

return copilotChat
