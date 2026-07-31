-- luacheck: globals describe it before_each after_each setup teardown assert

-- Resolve the absolute path to this spec's directory
local function get_spec_dir()
	local info = debug.getinfo(1, "S")
	local spec_file = info.source:gsub("^@", "")

	if not spec_file:match("^/") then
		local handle = io.popen("pwd")
		if handle then
			local cwd = handle:read("*l")
			handle:close()
			spec_file = cwd .. "/" .. spec_file
		end
	end

	return spec_file:match("(.*/)")
end

local spec_dir = get_spec_dir()

describe("yanky keymaps", function()
	local original_vim
	local calls

	setup(function()
		original_vim = _G.vim
	end)

	teardown(function()
		_G.vim = original_vim
	end)

	before_each(function()
		calls = {}
		_G.vim = {
			keymap = {
				set = function(mode, lhs, rhs, opts)
					table.insert(calls, { mode = mode, lhs = lhs, rhs = rhs, opts = opts })
				end,
			},
		}

		dofile(spec_dir .. "keymaps.lua").setup()
	end)

	--- Find a registered mapping by its left-hand side.
	local function find(lhs)
		for _, call in ipairs(calls) do
			if call.lhs == lhs then
				return call
			end
		end
		return nil
	end

	it("maps put to yanky so cycling works", function()
		assert.equals("<Plug>(YankyPutAfter)", find("p").rhs)
		assert.equals("<Plug>(YankyPutBefore)", find("P").rhs)
		assert.equals("<Plug>(YankyGPutAfter)", find("gp").rhs)
		assert.equals("<Plug>(YankyGPutBefore)", find("gP").rhs)
	end)

	it("maps put in both normal and visual mode", function()
		assert.same({ "n", "x" }, find("p").mode)
		assert.same({ "n", "x" }, find("P").mode)
	end)

	it("maps yank to yanky", function()
		assert.equals("<Plug>(YankyYank)", find("y").rhs)
		assert.same({ "n", "x" }, find("y").mode)
	end)

	it("maps history cycling in normal mode only", function()
		assert.equals("<Plug>(YankyPreviousEntry)", find("<C-p>").rhs)
		assert.equals("<Plug>(YankyNextEntry)", find("<C-n>").rhs)
		assert.equals("n", find("<C-p>").mode)
		assert.equals("n", find("<C-n>").mode)
	end)

	it("maps the telescope history picker", function()
		assert.equals("<cmd>Telescope yank_history<CR>", find("<leader>P").rhs)
		assert.equals("n", find("<leader>P").mode)
	end)

	it("does not use <leader>p, which pathtool owns as a prefix", function()
		assert.is_nil(find("<leader>p"))
	end)

	it("gives every mapping a description", function()
		for _, call in ipairs(calls) do
			assert.is_string(call.opts and call.opts.desc, call.lhs .. " must have a desc")
		end
	end)
end)
