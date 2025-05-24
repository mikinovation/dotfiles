local nvimTsAutotag = {}

function nvimTsAutotag.config()
	return {
		"windwp/nvim-ts-autotag",
		commit = "a1d526af391f6aebb25a8795cbc05351ed3620b5",
		event = "InsertEnter",
		config = true,
	}
end

return nvimTsAutotag
