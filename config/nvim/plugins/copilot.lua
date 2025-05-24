local copilot = {}

function copilot.config()
	return {
		"zbirenbaum/copilot.lua",
		commit = "a5c390f8d8e85b501b22dcb2f30e0cbbd69d5ff0",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	}
end

return copilot
