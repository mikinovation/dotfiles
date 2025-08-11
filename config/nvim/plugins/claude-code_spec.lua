describe("claudeCode plugin", function()
	local claudeCode

	before_each(function()
		-- Mock the plugins.plenary module
		package.preload["plugins.plenary"] = function()
			return {
				config = function()
					return {
						"nvim-lua/plenary.nvim",
						commit = "857c5ac632080dba10aae49dba902ce3abf91b35",
					}
				end,
			}
		end

		-- Mock the claude-code module
		package.preload["claude-code"] = function()
			return {
				setup = function() end,
				claude_code = {
					bufnr = 1,
				},
			}
		end

		claudeCode = require("config.nvim.plugins.claude-code")
	end)

	after_each(function()
		package.preload["plugins.plenary"] = nil
		package.preload["claude-code"] = nil
		package.loaded["config.nvim.plugins.claude-code"] = nil
	end)

	describe("config function", function()
		it("should return a valid plugin configuration", function()
			local config = claudeCode.config()

			assert.is_table(config)
			assert.is_equal("greggh/claude-code.nvim", config[1])
			assert.is_string(config.commit)
			assert.is_table(config.dependencies)
			assert.is_function(config.config)
		end)

		it("should have the correct commit hash", function()
			local config = claudeCode.config()
			assert.is_equal("91b38f289c9b1f08007a0443020ed97bb7539ebe", config.commit)
		end)

		it("should include plenary dependency", function()
			local config = claudeCode.config()
			assert.is_table(config.dependencies)
			assert.is_equal(1, #config.dependencies)
		end)
	end)

	describe("configuration setup", function()
		local config_spy

		before_each(function()
			config_spy = spy.new(function() end)
			package.preload["claude-code"] = function()
				return { setup = config_spy }
			end

			-- Mock vim globals for configuration
			_G.vim = {
				loop = {
					fs_stat = function()
						return nil
					end,
				},
				api = {
					nvim_create_user_command = function() end,
					nvim_buf_get_name = function()
						return "test.lua"
					end,
					nvim_buf_is_valid = function()
						return true
					end,
					nvim_buf_get_var = function()
						return 1
					end,
					nvim_chan_send = function() end,
					nvim_win_get_cursor = function()
						return { 1, 0 }
					end,
					nvim_buf_get_lines = function()
						return { "test line" }
					end,
				},
				ui = {
					select = function(items, _opts, callback)
						callback(items[1])
					end,
					input = function(_opts, callback)
						callback("test")
					end,
				},
				keymap = { set = function() end },
				cmd = function() end,
				defer_fn = function(fn)
					fn()
				end,
				fn = {
					getpos = function()
						return { 0, 1, 0, 0 }
					end,
					win_findbuf = function()
						return { 1 }
					end,
				},
				log = { levels = { WARN = 1, ERROR = 2, INFO = 3 } },
				notify = function() end,
				pesc = function(str)
					return str
				end,
				tbl_contains = function(t, v)
					for _, item in ipairs(t) do
						if item == v then
							return true
						end
					end
					return false
				end,
			}

			_G.io = {
				popen = function()
					return {
						read = function()
							return "/fake/git/root"
						end,
						close = function() end,
						lines = function()
							return function() end
						end,
					}
				end,
				open = function()
					return nil
				end,
			}
		end)

		after_each(function()
			_G.vim = nil
			_G.io = nil
			package.preload["claude-code"] = nil
		end)

		it("should call setup with correct configuration", function()
			local config = claudeCode.config()
			config.config()

			assert.spy(config_spy).was_called(1)
			local setup_args = config_spy.calls[1].refs[1]

			-- Test window configuration
			assert.is_table(setup_args.window)
			assert.is_equal(0.5, setup_args.window.split_ratio)
			assert.is_equal("vertical", setup_args.window.position)
			assert.is_true(setup_args.window.enter_insert)

			-- Test refresh configuration
			assert.is_table(setup_args.refresh)
			assert.is_true(setup_args.refresh.enable)
			assert.is_equal(100, setup_args.refresh.updatetime)

			-- Test command configuration
			assert.is_equal("claude", setup_args.command)
			assert.is_table(setup_args.command_variants)

			-- Test keymap configuration
			assert.is_table(setup_args.keymaps)
			assert.is_table(setup_args.keymaps.toggle)
		end)
	end)
end)
