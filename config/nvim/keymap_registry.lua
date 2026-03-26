-- keymap_registry.lua
-- Thin wrapper around vim.keymap.set that tracks all keymap registrations
-- and provides conflict detection.

local M = {}

-- Internal registry:
-- { { mode = "n", lhs = "<leader>ff", desc = "...", source = "...", scope = "global"|"buffer" }, ... }
M._registry = {}

-- Clear the registry (mainly for testing)
function M.clear()
	M._registry = {}
end

-- Register a keymap and record it in the registry.
-- @param source string: identifier for where this keymap comes from (e.g. "telescope", "lsp", "keymaps")
-- @param mode string|table: vim mode(s)
-- @param lhs string: key sequence
-- @param rhs string|function: action
-- @param opts table|nil: options (desc, buffer, etc.)
function M.set(source, mode, lhs, rhs, opts)
	opts = opts or {}
	local modes = type(mode) == "table" and mode or { mode }
	local scope = opts.buffer and "buffer" or "global"
	local desc = opts.desc or ""

	for _, m in ipairs(modes) do
		table.insert(M._registry, {
			mode = m,
			lhs = lhs,
			desc = desc,
			source = source,
			scope = scope,
		})
	end

	vim.keymap.set(mode, lhs, rhs, opts)
end

-- Find all conflicts in the registry.
-- A conflict is when two entries share the same (mode, lhs, scope) but come from different sources,
-- or when the same source registers the same key twice.
-- Buffer-local keymaps are checked separately from global ones.
-- @return table: list of conflict descriptions { { key = "...", mode = "...", entries = { ... } }, ... }
function M.validate()
	local conflicts = {}
	-- Group by (mode, lhs, scope)
	local groups = {}
	for _, entry in ipairs(M._registry) do
		local key = entry.mode .. "|" .. entry.lhs .. "|" .. entry.scope
		if not groups[key] then
			groups[key] = {}
		end
		table.insert(groups[key], entry)
	end

	for _, entries in pairs(groups) do
		if #entries > 1 then
			table.insert(conflicts, {
				mode = entries[1].mode,
				lhs = entries[1].lhs,
				scope = entries[1].scope,
				entries = entries,
			})
		end
	end

	-- Sort for deterministic output
	table.sort(conflicts, function(a, b)
		if a.lhs == b.lhs then
			return a.mode < b.mode
		end
		return a.lhs < b.lhs
	end)

	return conflicts
end

-- Format conflicts into a human-readable string
-- @param conflicts table: result from validate()
-- @return string
function M.format_conflicts(conflicts)
	if #conflicts == 0 then
		return "No keymap conflicts found."
	end

	local lines = { "Keymap conflicts detected:" }
	for _, conflict in ipairs(conflicts) do
		table.insert(lines, "")
		table.insert(lines, string.format("  [%s] %s (scope: %s):", conflict.mode, conflict.lhs, conflict.scope))
		for _, entry in ipairs(conflict.entries) do
			table.insert(lines, string.format("    - source: %s, desc: %s", entry.source, entry.desc))
		end
	end

	return table.concat(lines, "\n")
end

return M
