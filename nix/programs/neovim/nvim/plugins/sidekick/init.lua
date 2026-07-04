local sidekick = {}

function sidekick.config()
	return {
		"folke/sidekick.nvim",
		event = "VeryLazy",
		opts = {
			cli = {
				-- herdr is not a supported mux backend (only tmux/zellij are), so run
				-- the CLI agent inside a Neovim terminal window instead of a persistent
				-- mux pane. Direct-to-agent sending into herdr panes is handled by
				-- plugins.herdr.actions (see the <leader>h* keymaps below).
				mux = {
					enabled = false,
				},
			},
		},
		keys = {
			{
				"<tab>",
				function()
					if not require("sidekick").nes_jump_or_apply() then
						return "<Tab>"
					end
				end,
				expr = true,
				desc = "Goto/Apply Next Edit Suggestion",
			},
			{
				"<leader>aa",
				function()
					require("sidekick.cli").toggle({
						name = "claude",
						focus = true,
					})
				end,
				desc = "Sidekick Toggle Claude",
			},
			{
				"<leader>at",
				function()
					require("sidekick.cli").send({ msg = "{this}" })
				end,
				mode = { "x", "n" },
				desc = "Send This",
			},
			{
				"<leader>af",
				function()
					require("sidekick.cli").send({ msg = "{file}" })
				end,
				desc = "Send File",
			},
			{
				"<leader>av",
				function()
					require("sidekick.cli").send({ msg = "{selection}" })
				end,
				mode = { "x" },
				desc = "Send Visual Selection",
			},
			{
				"<leader>ap",
				function()
					require("sidekick.cli").prompt()
				end,
				mode = { "n", "x" },
				desc = "Sidekick Select Prompt",
			},
			{
				"<leader>hv",
				function()
					require("plugins.herdr.actions").send_selection()
				end,
				mode = { "x" },
				desc = "Herdr: Send Selection to Agent",
			},
			{
				"<leader>hp",
				function()
					require("plugins.herdr.actions").send_prompt()
				end,
				mode = { "n", "x" },
				desc = "Herdr: Send Prompt to Agent",
			},
			{
				"<leader>hl",
				function()
					require("plugins.herdr.actions").send_current_line()
				end,
				desc = "Herdr: Send Current Line to Agent",
			},
			{
				"<leader>hf",
				function()
					require("plugins.herdr.actions").send_buffer_path()
				end,
				desc = "Herdr: Send Buffer Path to Agent",
			},
			{
				"<leader>hs",
				function()
					require("plugins.herdr.actions").start_claude()
				end,
				desc = "Herdr: Start Claude Agent Here",
			},
		},
	}
end

return sidekick
