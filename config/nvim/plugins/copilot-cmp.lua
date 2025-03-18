local copilotCmp = {}

function copilotCmp.config()
	return {
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	}
end

return copilotCmp
