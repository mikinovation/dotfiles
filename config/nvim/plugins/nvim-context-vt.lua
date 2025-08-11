local nvimContextVt = {}

function nvimContextVt.config()
	return {
		"andersevenrud/nvim_context_vt",
		config = function()
			require("nvim_context_vt").setup()
		end,
	}
end

return nvimContextVt
