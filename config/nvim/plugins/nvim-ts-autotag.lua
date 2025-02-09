local nvimTsAutotag = {}

function nvimTsAutotag.config()
	return {
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		config = true
	}
end

return nvimTsAutotag
