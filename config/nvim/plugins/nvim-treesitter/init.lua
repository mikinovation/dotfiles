local nvimTreesitter = {}

function nvimTreesitter.config()
	return { -- Highlight, edit, and navigate code
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local parsers = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			}

			local ts = require("nvim-treesitter")
			local installed = ts.get_installed()

			local to_install = {}
			for _, parser in ipairs(parsers) do
				if not vim.list_contains(installed, parser) then
					table.insert(to_install, parser)
				end
			end

			if #to_install > 0 then
				ts.install(to_install)
			end

			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local ft = args.match
					local lang = vim.treesitter.language.get_lang(ft) or ft
					local ok = pcall(vim.treesitter.language.inspect, lang)
					if ok then
						vim.treesitter.start()
						vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})
		end,
	}
end

return nvimTreesitter
