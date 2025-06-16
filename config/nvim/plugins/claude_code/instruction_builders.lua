local git_operations = require("config.nvim.plugins.claude_code.git_operations")

local instruction_builders = {}

function instruction_builders.build_commit_instruction(state)
	local parts = {
		"I'm going to create a git commit. Please follow these instructions:",
		"- Create a commit in " .. state.language .. " language",
		"- Follow conventional commits format (e.g., `feat:`, `fix:`, `chore:`)",
		"- Use git status to see what files have changed",
		"- Use git diff to understand the changes",
		"- Create the commit using git commit -m with an appropriate message",
		"- Do NOT add any AI attribution lines to the commit message",
	}
	return table.concat(parts, "\n")
end

function instruction_builders.build_issue_instruction(state)
	local parts = {
		"I'm going to create a GitHub issue. I will use gh command. Please follow these instructions:",
		"- Create an issue in " .. state.language .. " language",
		"- Use gh issue create command to create the issue",
	}

	if git_operations.check_template_exists("/.github/ISSUE_TEMPLATE") then
		table.insert(
			parts,
			"- Please check if there are templates in .github/ISSUE_TEMPLATE and use the appropriate template"
		)
	end

	return table.concat(parts, "\n")
end

function instruction_builders.build_pr_instruction(state)
	local parts = {
		"I'm going to create a pull request. I will use gh command. Please follow these instructions:",
		"- Create a PR in " .. state.language .. " language",
		"- Set PR status to " .. (state.draft_mode == "draft" and "draft" or "open"),
		"- Assign myself to the PR",
	}

	if state.base_branch and state.base_branch ~= "" then
		table.insert(parts, "- Use '" .. state.base_branch .. "' as the base branch for the PR")
		table.insert(parts, "- Before pushing, rebase from origin/" .. state.base_branch)
	end

	if state.ticket and state.ticket ~= "" then
		table.insert(parts, "- With ticket reference: " .. state.ticket)
	end

	local pr_template_path = git_operations.find_pr_template()
	if pr_template_path then
		table.insert(
			parts,
			"- Please follow the template format in "
				.. pr_template_path:sub(2)
				.. ". Do NOT translate the title/headings from the PR template."
		)
	end

	return table.concat(parts, "\n")
end

function instruction_builders.build_push_instruction(state)
	local parts = {
		"I'm going to push changes. Please follow these instructions:",
		"- First, check if a pull request already exists for the current branch with Github CLI",
	}

	if state.base_branch and state.base_branch ~= "" then
		table.insert(
			parts,
			"- If a PR exists, use git merge to update from origin/" .. state.base_branch .. " before pushing"
		)
		table.insert(parts, "- If no PR exists, use git rebase from origin/" .. state.base_branch .. " before pushing")
	else
		table.insert(parts, "- If a PR exists, use git merge to update from the base branch before pushing")
		table.insert(parts, "- If no PR exists, use git rebase from the base branch before pushing")
	end

	table.insert(parts, "- After the merge/rebase is successful, push the changes to origin")

	return table.concat(parts, "\n")
end

function instruction_builders.build_create_branch_instruction(state)
	local parts = {
		"I'm going to create a new git branch. Please follow these instructions:",
		"- Ticket title: " .. state.title,
		"- Generate an appropriate branch name based on the ticket title",
		"- Use conventional branch naming (e.g., feature/, fix/, chore/)",
	}
	return table.concat(parts, "\n")
end

return instruction_builders
