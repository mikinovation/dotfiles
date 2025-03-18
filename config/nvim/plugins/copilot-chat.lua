local copilotChat = {}

function copilotChat.config()
	return {
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			require("plugins.plenary").config(),
		},
		opts = {},
	}
end

return copilotChat
