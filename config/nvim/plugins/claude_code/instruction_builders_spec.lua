describe("instruction_builders", function()
	local instruction_builders
	local git_operations
	local original_vim

	before_each(function()
		-- Mock vim global
		original_vim = _G.vim
		_G.vim = {
			loop = {
				fs_stat = function()
					return nil
				end,
			},
			pesc = function(str)
				return str:gsub("([%-%.%+%[%]%(%)%$%^%%%?%*])", "%%%1")
			end,
		}

		-- Mock git_operations
		package.preload["config.nvim.plugins.claude_code.git_operations"] = function()
			return {
				check_template_exists = function()
					return false
				end,
				find_pr_template = function()
					return nil
				end,
			}
		end

		instruction_builders = require("config.nvim.plugins.claude_code.instruction_builders")
		git_operations = require("config.nvim.plugins.claude_code.git_operations")
	end)

	after_each(function()
		_G.vim = original_vim
		package.preload["config.nvim.plugins.claude_code.git_operations"] = nil
		package.loaded["config.nvim.plugins.claude_code.instruction_builders"] = nil
		package.loaded["config.nvim.plugins.claude_code.git_operations"] = nil
	end)

	describe("build_commit_instruction", function()
		it("should build commit instruction with language", function()
			local state = { language = "en" }
			local result = instruction_builders.build_commit_instruction(state)

			assert.is_string(result)
			assert.is_true(string.find(result, "Create a commit in en language") ~= nil)
			assert.is_true(string.find(result, "conventional commits format") ~= nil)
			assert.is_true(string.find(result, "Do NOT add any AI attribution") ~= nil)
		end)

		it("should include all required instructions", function()
			local state = { language = "ja" }
			local result = instruction_builders.build_commit_instruction(state)

			local required_parts = {
				"git commit",
				"git status",
				"git diff",
				"conventional commits",
				"ja language",
			}

			for _, part in ipairs(required_parts) do
				assert.is_true(string.find(result, part) ~= nil, "Missing: " .. part)
			end
		end)
	end)

	describe("build_issue_instruction", function()
		it("should build basic issue instruction", function()
			local state = { language = "en" }
			local result = instruction_builders.build_issue_instruction(state)

			assert.is_string(result)
			assert.is_true(string.find(result, "Create an issue in en language") ~= nil)
			assert.is_true(string.find(result, "gh issue create") ~= nil)
		end)

		it("should include template instruction when template exists", function()
			stub(git_operations, "check_template_exists").returns(true)

			local state = { language = "en" }
			local result = instruction_builders.build_issue_instruction(state)

			assert.is_true(string.find(result, "check if there are templates") ~= nil)
		end)

		it("should not include template instruction when template does not exist", function()
			stub(git_operations, "check_template_exists").returns(false)

			local state = { language = "en" }
			local result = instruction_builders.build_issue_instruction(state)

			assert.is_true(string.find(result, "check if there are templates") == nil)
		end)
	end)

	describe("build_pr_instruction", function()
		it("should build basic PR instruction", function()
			local state = {
				language = "en",
				draft_mode = "open",
			}
			local result = instruction_builders.build_pr_instruction(state)

			assert.is_string(result)
			assert.is_true(string.find(result, "Create a PR in en language") ~= nil)
			assert.is_true(string.find(result, "Set PR status to open") ~= nil)
			assert.is_true(string.find(result, "Assign myself") ~= nil)
		end)

		it("should handle draft mode", function()
			local state = {
				language = "ja",
				draft_mode = "draft",
			}
			local result = instruction_builders.build_pr_instruction(state)

			assert.is_true(string.find(result, "Set PR status to draft") ~= nil)
		end)

		it("should include base branch instructions when provided", function()
			local state = {
				language = "en",
				draft_mode = "open",
				base_branch = "main",
			}
			local result = instruction_builders.build_pr_instruction(state)

			assert.is_true(string.find(result, "Use 'main' as the base branch") ~= nil)
			assert.is_true(string.find(result, "rebase from origin/main") ~= nil)
		end)

		it("should include ticket reference when provided", function()
			local state = {
				language = "en",
				draft_mode = "open",
				ticket = "TICKET-123",
			}
			local result = instruction_builders.build_pr_instruction(state)

			assert.is_true(string.find(result, "With ticket reference: TICKET%-123") ~= nil)
		end)

		it("should include PR template instructions when template exists", function()
			stub(git_operations, "find_pr_template").returns("/.github/pull_request_template.md")

			local state = {
				language = "en",
				draft_mode = "open",
			}
			local result = instruction_builders.build_pr_instruction(state)

			assert.is_true(string.find(result, "follow the template format") ~= nil)
			assert.is_true(string.find(result, ".github/pull_request_template.md") ~= nil)
		end)
	end)

	describe("build_push_instruction", function()
		it("should build basic push instruction", function()
			local state = {}
			local result = instruction_builders.build_push_instruction(state)

			assert.is_string(result)
			assert.is_true(string.find(result, "check if a pull request already exists") ~= nil)
			assert.is_true(string.find(result, "push the changes to origin") ~= nil)
		end)

		it("should include specific base branch instructions when provided", function()
			local state = { base_branch = "develop" }
			local result = instruction_builders.build_push_instruction(state)

			assert.is_true(string.find(result, "origin/develop") ~= nil)
			assert.is_true(string.find(result, "git merge.*origin/develop") ~= nil)
			assert.is_true(string.find(result, "git rebase.*origin/develop") ~= nil)
		end)

		it("should use generic base branch instructions when base_branch not provided", function()
			local state = {}
			local result = instruction_builders.build_push_instruction(state)

			assert.is_true(string.find(result, "from the base branch") ~= nil)
			assert.is_false(string.find(result, "origin/") ~= nil)
		end)
	end)

	describe("build_create_branch_instruction", function()
		it("should build create branch instruction with title", function()
			local state = { title = "Fix user authentication bug" }
			local result = instruction_builders.build_create_branch_instruction(state)

			assert.is_string(result)
			assert.is_true(string.find(result, "Ticket title: Fix user authentication bug") ~= nil)
			assert.is_true(string.find(result, "Generate an appropriate branch name") ~= nil)
			assert.is_true(string.find(result, "conventional branch naming") ~= nil)
			assert.is_true(string.find(result, "feature/, fix/, chore/") ~= nil)
		end)
	end)
end)
