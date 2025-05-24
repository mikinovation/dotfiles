local nvimDap = {}

function nvimDap.config()
	return {
		"mfussenegger/nvim-dap",
		commit = "8df427aeba0a06c6577dc3ab82de3076964e3b8d",
		dependencies = {
			require("plugins.nvim-dap-virtual-text").config(),
			require("plugins.nvim-dap-ui").config(),
			require("plugins.nvim-dap-vscode-js").config(),
			require("plugins.vscode-js-debug").config(),
		},
		lazy = true,
		config = function()
			local dap = require("dap")

			require("dap-vscode-js").setup({
				debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
				adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
			})

			for _, language in ipairs({ "typescript", "javascript", "typescriptreact" }) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "launch",
						name = "Debug Jest Tests",
						runtimeExecutable = "node",
						runtimeArgs = { "./node_modules/jest/bin/jest.js", "--runInBand" },
						rootPath = "${workspaceFolder}",
						cwd = "${workspaceFolder}",
						console = "integratedTerminal",
						internalConsoleOptions = "neverOpen",
					},
				}
			end
		end,
	}
end

return nvimDap
