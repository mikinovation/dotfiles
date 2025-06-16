local claude_client = {}

function claude_client.send_to_claude(instruction_text)
	local claude_code_module = require("claude-code")
	local bufnr = claude_code_module.claude_code.bufnr
	local window_exists = false

	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		local win_ids = vim.fn.win_findbuf(bufnr)
		window_exists = #win_ids > 0
	end

	if not window_exists then
		vim.cmd("ClaudeCode")
	end

	vim.defer_fn(function()
		local updated_bufnr = claude_code_module.claude_code.bufnr
		if updated_bufnr and vim.api.nvim_buf_is_valid(updated_bufnr) then
			local chan_id = vim.api.nvim_buf_get_var(updated_bufnr, "terminal_job_id")
			if chan_id then
				vim.api.nvim_chan_send(chan_id, instruction_text)
			end
		end
	end, window_exists and 100 or 1000)
end

function claude_client.send_file_paths_to_claude(file_paths)
	if not file_paths or #file_paths == 0 then
		vim.notify("No files selected", vim.log.levels.WARN)
		return
	end

	local file_paths_text = table.concat(file_paths, " ")
	claude_client.send_to_claude(file_paths_text)
end

function claude_client.send_lines_to_claude(lines, file_info)
	if not lines or #lines == 0 then
		vim.notify("No lines to send", vim.log.levels.WARN)
		return
	end

	local content_parts = {}
	if file_info then
		local line_info = file_info.line_start == file_info.line_end and file_info.line_start
			or file_info.line_start .. "-" .. file_info.line_end
		table.insert(content_parts, file_info.path .. ":" .. line_info)
		table.insert(content_parts, "")
	end

	local content = table.concat(content_parts, "\n")
	claude_client.send_to_claude(content)
end

return claude_client
