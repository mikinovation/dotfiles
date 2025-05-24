local nvimAutopairs = {}

function nvimAutopairs.config()
	return {
		"windwp/nvim-autopairs",
		commit = "84a81a7d1f28b381b32acf1e8fe5ff5bef4f7968",
		event = "InsertEnter",
		config = true,
	}
end

return nvimAutopairs
