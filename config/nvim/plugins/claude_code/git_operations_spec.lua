describe("git_operations", function()
	local git_operations

	before_each(function()
		git_operations = require("plugins.claude_code.git_operations")
	end)

	after_each(function()
		package.loaded["plugins.claude_code.git_operations"] = nil
	end)

	describe("get_git_root", function()
		local original_io

		before_each(function()
			original_io = _G.io
		end)

		after_each(function()
			_G.io = original_io
		end)

		it("should return git root path when git repo exists", function()
			_G.io = {
				popen = function(cmd)
					if cmd == "git rev-parse --show-toplevel 2>/dev/null" then
						return {
							read = function()
								return "/path/to/git/root\n"
							end,
							close = function() end,
						}
					end
					return nil
				end,
			}

			local result = git_operations.get_git_root()
			assert.is_equal("/path/to/git/root", result)
		end)

		it("should return nil when not in git repo", function()
			_G.io = {
				popen = function()
					return nil
				end,
			}

			local result = git_operations.get_git_root()
			assert.is_nil(result)
		end)

		it("should return nil when git command returns empty string", function()
			_G.io = {
				popen = function()
					return {
						read = function()
							return ""
						end,
						close = function() end,
					}
				end,
			}

			local result = git_operations.get_git_root()
			assert.is_nil(result)
		end)
	end)

	describe("check_template_exists", function()
		local original_vim

		before_each(function()
			original_vim = _G.vim
			_G.vim = {
				loop = {
					fs_stat = function()
						return nil
					end,
				},
				pesc = function(str)
					return str
				end,
			}
		end)

		after_each(function()
			_G.vim = original_vim
		end)

		it("should return true when template exists", function()
			stub(git_operations, "get_git_root").returns("/git/root")
			_G.vim.loop.fs_stat = function(path)
				if path == "/git/root/.github/ISSUE_TEMPLATE" then
					return { type = "directory" }
				end
				return nil
			end

			local result = git_operations.check_template_exists("/.github/ISSUE_TEMPLATE")
			assert.is_true(result)
		end)

		it("should return false when template does not exist", function()
			stub(git_operations, "get_git_root").returns("/git/root")
			_G.vim.loop.fs_stat = function()
				return nil
			end

			local result = git_operations.check_template_exists("/.github/ISSUE_TEMPLATE")
			assert.is_false(result)
		end)

		it("should return false when not in git repo", function()
			stub(git_operations, "get_git_root").returns(nil)

			local result = git_operations.check_template_exists("/.github/ISSUE_TEMPLATE")
			assert.is_false(result)
		end)
	end)

	describe("find_pr_template", function()
		local original_vim

		before_each(function()
			original_vim = _G.vim
			_G.vim = {
				loop = {
					fs_stat = function()
						return nil
					end,
				},
			}
		end)

		after_each(function()
			_G.vim = original_vim
		end)

		it("should return first found template path", function()
			stub(git_operations, "get_git_root").returns("/git/root")
			_G.vim.loop.fs_stat = function(path)
				if path == "/git/root/.github/pull_request_template.md" then
					return { type = "file" }
				end
				return nil
			end

			local result = git_operations.find_pr_template()
			assert.is_equal("/.github/pull_request_template.md", result)
		end)

		it("should return nil when no template found", function()
			stub(git_operations, "get_git_root").returns("/git/root")
			_G.vim.loop.fs_stat = function()
				return nil
			end

			local result = git_operations.find_pr_template()
			assert.is_nil(result)
		end)

		it("should return nil when not in git repo", function()
			stub(git_operations, "get_git_root").returns(nil)

			local result = git_operations.find_pr_template()
			assert.is_nil(result)
		end)
	end)

	describe("get_remote_branches", function()
		local original_io

		before_each(function()
			original_io = _G.io
		end)

		after_each(function()
			_G.io = original_io
		end)

		it("should return list of remote branches", function()
			local fetch_called = false
			local branch_lines = { "main", "develop", "feature/test" }
			local line_index = 0

			_G.io = {
				popen = function(cmd)
					if cmd == "git fetch 2>&1" then
						fetch_called = true
						return {
							read = function()
								return ""
							end,
							close = function() end,
						}
					elseif string.find(cmd, "git branch") then
						return {
							lines = function()
								return function()
									line_index = line_index + 1
									return branch_lines[line_index]
								end
							end,
							close = function() end,
						}
					end
					return nil
				end,
			}

			local result = git_operations.get_remote_branches()
			assert.is_true(fetch_called)
			assert.are.same({ "main", "develop", "feature/test" }, result)
		end)

		it("should return empty table when git command fails", function()
			_G.io = {
				popen = function()
					return nil
				end,
			}

			local result = git_operations.get_remote_branches()
			assert.are.same({}, result)
		end)
	end)

	describe("get_relative_path", function()
		local original_vim

		before_each(function()
			original_vim = _G.vim
			_G.vim = {
				pesc = function(str)
					return str:gsub("([%-%.%+%[%]%(%)%$%^%%%?%*])", "%%%1")
				end,
			}
		end)

		after_each(function()
			_G.vim = original_vim
		end)

		it("should return relative path when in git repo", function()
			stub(git_operations, "get_git_root").returns("/git/root")

			local result = git_operations.get_relative_path("/git/root/src/file.lua")
			assert.is_equal("src/file.lua", result)
		end)

		it("should return original path when not in git repo", function()
			stub(git_operations, "get_git_root").returns(nil)

			local result = git_operations.get_relative_path("/some/path/file.lua")
			assert.is_equal("/some/path/file.lua", result)
		end)
	end)
end)
