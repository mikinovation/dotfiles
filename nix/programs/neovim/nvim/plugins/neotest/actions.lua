-- plugins/neotest/actions.lua

local M = {}

--- Run the test nearest to the cursor.
function M.run_nearest()
	require("neotest").run.run()
end

--- Run the test nearest to the cursor under the DAP debugger.
function M.debug_nearest()
	require("neotest").run.run({ strategy = "dap" })
end

--- Run all tests in the current file.
function M.run_file()
	require("neotest").run.run(vim.fn.expand("%"))
end

return M
