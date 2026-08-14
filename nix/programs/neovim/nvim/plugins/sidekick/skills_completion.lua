-- plugins/sidekick/skills_completion.lua
-- blink.cmp source that completes installed Claude Code skill names as
-- `/skill-name` while drafting prompts in org/markdown buffers (the text then
-- goes to the CLI agent via plugins/sidekick or plugins/herdr).
--
-- Skills are discovered on disk rather than hardcoded: ~/.claude/skills is the
-- merged output of nix (nix/programs/claude-code/skills) and agent-skills, and
-- each project may add its own <cwd>/.claude/skills. On a name clash the
-- project copy wins, since that is what Claude itself resolves.

local M = {}

-- Deployed skills are flat (`commit-commands:create-branch` is one directory),
-- but a source tree may nest one level under a plugin directory, so descend
-- twice before giving up.
M.MAX_DEPTH = 2

M.filetypes = { org = true, markdown = true }

--- Strip surrounding whitespace and quotes from a YAML scalar.
---@param value string
---@return string
local function unquote(value)
	value = value:gsub("^%s+", ""):gsub("%s+$", "")
	return value:match('^"(.*)"$') or value:match("^'(.*)'$") or value
end

--- Append `name` to a copy of `segments`, leaving the original untouched.
---@param segments string[]
---@param name string
---@return string[]
local function extend(segments, name)
	local copy = {}
	for _, segment in ipairs(segments) do
		table.insert(copy, segment)
	end
	table.insert(copy, name)
	return copy
end

--- Read `name` and `description` out of a SKILL.md YAML frontmatter block.
--- Only the leading `---` ... `---` block is read, and only single-line scalars:
--- top-level keys are anchored so nested ones (`metadata:` children) are ignored.
---@param text string
---@return table
function M.parse_frontmatter(text)
	local body = text:match("^%-%-%-\n(.-)\n%-%-%-")
	if not body then
		return {}
	end

	local result = {}
	for line in (body .. "\n"):gmatch("(.-)\n") do
		local key, value = line:match("^([%w_-]+):%s*(.*)$")
		if key == "name" or key == "description" then
			result[key] = unquote(value)
		end
	end
	return result
end

--- The identifier Claude accepts after `/`: the frontmatter `name` when present,
--- otherwise the path segments below the skills root joined with `:`.
---@param segments string[]
---@param frontmatter table|nil
---@return string
function M.skill_name(segments, frontmatter)
	local name = frontmatter and frontmatter.name
	if name and name ~= "" then
		return name
	end
	return table.concat(segments, ":")
end

--- Merge two skill lists, letting the later list win on a name clash, and sort
--- the result by name so the completion menu has a stable order.
---@param global_skills table[]|nil
---@param local_skills table[]|nil
---@return table[]
function M.merge(global_skills, local_skills)
	local by_name = {}
	for _, list in ipairs({ global_skills or {}, local_skills or {} }) do
		for _, skill in ipairs(list) do
			by_name[skill.name] = skill
		end
	end

	local merged = {}
	for _, skill in pairs(by_name) do
		table.insert(merged, skill)
	end
	table.sort(merged, function(a, b)
		return a.name < b.name
	end)
	return merged
end

--- Build blink.cmp items. The `/` is part of the label and filter text: the
--- trigger character stays in the buffer, so matching bare names would drop
--- every candidate the moment `/` is typed.
---@param skills table[]
---@return table[]
function M.to_items(skills)
	local items = {}
	for _, skill in ipairs(skills) do
		local label = "/" .. skill.name
		table.insert(items, {
			label = label,
			filterText = label,
			insertText = label,
			documentation = skill.description,
		})
	end
	return items
end

--- Read one candidate directory; nil when it holds no SKILL.md.
---@param dir string
---@param segments string[]
---@return table|nil
function M.read_skill(dir, segments)
	local file = io.open(dir .. "/SKILL.md", "r")
	if not file then
		return nil
	end
	local text = file:read("*a")
	file:close()

	local frontmatter = M.parse_frontmatter(text)
	return { name = M.skill_name(segments, frontmatter), description = frontmatter.description }
end

--- Collect the skills under `root`. Entry types are not filtered because most
--- entries are symlinks into the nix store; a non-directory simply yields no
--- SKILL.md and no scandir handle.
---@param root string
---@param segments string[]|nil
---@param depth integer|nil
---@return table[]
function M.scan(root, segments, depth)
	segments = segments or {}
	depth = depth or 1

	local skills = {}
	local handle = vim.loop.fs_scandir(root)
	if not handle then
		return skills
	end

	while true do
		local name = vim.loop.fs_scandir_next(handle)
		if not name then
			break
		end

		local dir = root .. "/" .. name
		local nested = extend(segments, name)
		local skill = M.read_skill(dir, nested)
		if skill then
			table.insert(skills, skill)
		elseif depth < M.MAX_DEPTH then
			for _, found in ipairs(M.scan(dir, nested, depth + 1)) do
				table.insert(skills, found)
			end
		end
	end
	return skills
end

--- Skills roots, global first so the project one overrides it in M.merge.
---@return string[]
function M.roots()
	local global_root = vim.fn.expand("~/.claude/skills")
	local project_root = vim.fn.getcwd() .. "/.claude/skills"
	if project_root == global_root then
		return { global_root }
	end
	return { global_root, project_root }
end

--- Cache key built from the roots' mtimes, so adding or removing a skill is
--- picked up without restarting Neovim. Nanoseconds are part of the key because
--- whole seconds are too coarse to notice a skill added moments after the first
--- completion. Edits *inside* an existing skill do not bump the parent mtime,
--- but only name and description are cached here.
---@param roots string[]
---@return string
function M.cache_key(roots)
	local parts = {}
	for _, root in ipairs(roots) do
		local stat = vim.loop.fs_stat(root)
		local mtime = stat and stat.mtime or { sec = 0, nsec = 0 }
		table.insert(parts, ("%s@%d.%d"):format(root, mtime.sec, mtime.nsec or 0))
	end
	return table.concat(parts, ",")
end

M._cache = nil
M._cache_key = nil

--- All available skills, cached until a root directory changes.
---@return table[]
function M.discover()
	local roots = M.roots()
	local key = M.cache_key(roots)
	if M._cache and M._cache_key == key then
		return M._cache
	end

	M._cache = M.merge(M.scan(roots[1]), roots[2] and M.scan(roots[2]) or {})
	M._cache_key = key
	return M._cache
end

M.__index = M

---@return table
function M.new()
	return setmetatable({}, M)
end

---@return boolean
function M.enabled(_)
	return M.filetypes[vim.bo.filetype] == true
end

---@return string[]
function M.get_trigger_characters(_)
	return { "/" }
end

---@param _context table
---@param callback fun(response: table)
function M.get_completions(_, _context, callback)
	callback({
		items = M.to_items(M.discover()),
		is_incomplete_backward = false,
		is_incomplete_forward = false,
	})
end

return M
