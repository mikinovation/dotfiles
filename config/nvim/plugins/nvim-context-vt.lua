local nvimContextVt = {}

function nvimContextVt.config()
	return {
		"andersevenrud/nvim_context_vt",
		commit = "10e13ec47a9bb341192d893e58cf91c61cde4935",
		config = function()
			require("nvim_context_vt").setup()
		end,
	}
end

return nvimContextVt
