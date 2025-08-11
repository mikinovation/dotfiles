local nvimNotify = {}

function nvimNotify.config()
	return {
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({
				stages = "fade_in_slide_out",
				timeout = 5000,
				highlight = "Normal",
				icons = {
					ERROR = "",
					WARN = "",
					INFO = "",
					DEBUG = "",
					TRACE = "✎",
				},
			})
			vim.notify = notify
		end,
	}
end

return nvimNotify
