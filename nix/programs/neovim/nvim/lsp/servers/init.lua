-- lsp/servers/init.lua

-- capabilities - integration with blink.cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

local profile = require("profile")

-- Load each server configuration
require("lsp.servers.lua_ls")(capabilities)
require("lsp.servers.nil_ls")(capabilities)
require("lsp.servers.tinymist")(capabilities)

local enabled_servers = { "lua_ls", "nil_ls", "tinymist" }

-- light プロファイルには以下の言語サーバのバイナリが入っていないため、
-- 起動しようとしてエラーになるのを避けて設定ごと読み込まない
if profile.is_full() then
	require("lsp.servers.rust_analyzer")(capabilities)
	require("lsp.servers.typescript")(capabilities)
	require("lsp.servers.tailwindcss")(capabilities)
	require("lsp.servers.solargraph")(capabilities)

	vim.list_extend(enabled_servers, {
		"rust_analyzer",
		"vtsls",
		"vue_ls",
		"tailwindcss",
		"solargraph",
	})
end

-- Enable all configured LSP servers
vim.lsp.enable(enabled_servers)
