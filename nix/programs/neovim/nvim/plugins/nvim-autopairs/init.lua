local nvimAutopairs = {}

function nvimAutopairs.config()
	return {
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	}
end

return nvimAutopairs
