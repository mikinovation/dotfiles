local copilotCmp = {}

function copilotCmp.config()
	return {
		"zbirenbaum/copilot-cmp",
		commit = "15fc12af3d0109fa76b60b5cffa1373697e261d1",
		config = function()
			require("copilot_cmp").setup()
		end,
	}
end

return copilotCmp
