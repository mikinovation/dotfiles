local blinkCmp = {}

function blinkCmp.config()
	return {
		"saghen/blink.cmp",
		version = "1.*",
		build = "cargo build --release",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			require("plugins.luasnip").config(),
		},
		opts = {
			keymap = {
				preset = "none",
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
				["<CR>"] = { "accept", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<Tab>"] = { "select_next", "snippet_forward", "show", "fallback" },
				["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			},
			snippets = { preset = "luasnip" },
			completion = {
				list = { selection = { preselect = false, auto_insert = false } },
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = false },
				accept = { auto_brackets = { enabled = true } },
			},
			signature = { enabled = true },
			fuzzy = { implementation = "prefer_rust_with_warning" },
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "lazydev" },
				per_filetype = {
					org = { inherit_defaults = true, "orgmode", "okf" },
				},
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
					orgmode = {
						name = "Orgmode",
						module = "orgmode.org.autocompletion.blink",
						fallbacks = { "buffer" },
					},
					okf = {
						name = "OKF",
						module = "plugins.org-roam.okf_completion",
					},
				},
			},
			cmdline = {
				keymap = { preset = "cmdline" },
				completion = { menu = { auto_show = true } },
			},
		},
	}
end

return blinkCmp
