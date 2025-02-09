local copilotChat = {}

function copilotChat.config()
	return {
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			{ "github/copilot.vim", branch = "release" },
			require("plugins.plenary").config(),
		},
		opts = {},
	}
end

return copilotChat
