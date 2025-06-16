describe("claude_client", function()
	local claude_client
	local original_vim

	before_each(function()
		-- Mock vim globals
		original_vim = _G.vim
		_G.vim = {
			api = {
				nvim_buf_is_valid = function()
					return true
				end,
				nvim_buf_get_var = function()
					return 123
				end,
				nvim_chan_send = spy.new(function() end),
			},
			fn = {
				win_findbuf = function()
					return { 1 }
				end,
			},
			cmd = spy.new(function() end),
			defer_fn = function(fn)
				fn()
			end,
			log = {
				levels = {
					WARN = 1,
					ERROR = 2,
				},
			},
			notify = spy.new(function() end),
		}

		-- Mock claude-code module
		package.preload["claude-code"] = function()
			return {
				claude_code = {
					bufnr = 1,
				},
			}
		end

		claude_client = require("config.nvim.plugins.claude_client")
	end)

	after_each(function()
		_G.vim = original_vim
		package.preload["claude-code"] = nil
		package.loaded["config.nvim.plugins.claude_client"] = nil
	end)

	describe("send_to_claude", function()
		it("should send instruction to existing Claude window", function()
			local instruction = "test instruction"

			claude_client.send_to_claude(instruction)

			assert.spy(_G.vim.api.nvim_chan_send).was_called_with(123, instruction)
		end)

		it("should open Claude window if it doesn't exist", function()
			_G.vim.fn.win_findbuf = function()
				return {}
			end

			local instruction = "test instruction"
			claude_client.send_to_claude(instruction)

			assert.spy(_G.vim.cmd).was_called_with("ClaudeCode")
			assert.spy(_G.vim.api.nvim_chan_send).was_called_with(123, instruction)
		end)

		it("should handle invalid buffer", function()
			_G.vim.api.nvim_buf_is_valid = function()
				return false
			end

			local instruction = "test instruction"
			claude_client.send_to_claude(instruction)

			assert.spy(_G.vim.cmd).was_called_with("ClaudeCode")
		end)
	end)

	describe("send_file_paths_to_claude", function()
		it("should send concatenated file paths", function()
			local send_to_claude_spy = spy.on(claude_client, "send_to_claude")

			local file_paths = { "file1.lua", "file2.lua", "file3.lua" }
			claude_client.send_file_paths_to_claude(file_paths)

			assert.spy(send_to_claude_spy).was_called_with("file1.lua file2.lua file3.lua")
		end)

		it("should notify when no files provided", function()
			claude_client.send_file_paths_to_claude({})

			assert.spy(_G.vim.notify).was_called_with("No files selected", 1)
		end)

		it("should notify when file_paths is nil", function()
			claude_client.send_file_paths_to_claude(nil)

			assert.spy(_G.vim.notify).was_called_with("No files selected", 1)
		end)
	end)

	describe("send_lines_to_claude", function()
		it("should send lines with file info", function()
			local send_to_claude_spy = spy.on(claude_client, "send_to_claude")

			local lines = { "line1", "line2" }
			local file_info = {
				path = "test.lua",
				line_start = 1,
				line_end = 2,
			}

			claude_client.send_lines_to_claude(lines, file_info)

			assert.spy(send_to_claude_spy).was_called_with("test.lua:1-2\n")
		end)

		it("should handle single line", function()
			local send_to_claude_spy = spy.on(claude_client, "send_to_claude")

			local lines = { "single line" }
			local file_info = {
				path = "test.lua",
				line_start = 5,
				line_end = 5,
			}

			claude_client.send_lines_to_claude(lines, file_info)

			assert.spy(send_to_claude_spy).was_called_with("test.lua:5\n")
		end)

		it("should send lines without file info", function()
			local send_to_claude_spy = spy.on(claude_client, "send_to_claude")

			local lines = { "line1", "line2" }
			claude_client.send_lines_to_claude(lines, nil)

			assert.spy(send_to_claude_spy).was_called_with("")
		end)

		it("should notify when no lines provided", function()
			claude_client.send_lines_to_claude({}, nil)

			assert.spy(_G.vim.notify).was_called_with("No lines to send", 1)
		end)

		it("should notify when lines is nil", function()
			claude_client.send_lines_to_claude(nil, nil)

			assert.spy(_G.vim.notify).was_called_with("No lines to send", 1)
		end)
	end)
end)
