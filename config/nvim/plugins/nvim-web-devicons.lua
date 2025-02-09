local nvimWebDevicons = {}

function nvimWebDevicons.config()
	return {
		"nvim-tree/nvim-web-devicons",
		enabled = vim.g.have_nerd_font,
	}
end

return nvimWebDevicons
