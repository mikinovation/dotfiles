local nvimNotify = {}

function nvimNotify.config()
	return {
		"rcarriga/nvim-notify",
		commit = "b5825cf9ee881dd8e43309c93374ed5b87b7a896",
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
