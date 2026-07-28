-- lsp/servers/init.lua

-- capabilities - integration with blink.cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

-- Load each server configuration
require("lsp.servers.lua_ls")(capabilities)
require("lsp.servers.rust_analyzer")(capabilities)
require("lsp.servers.typescript")(capabilities)
require("lsp.servers.tailwindcss")(capabilities)
require("lsp.servers.solargraph")(capabilities)
require("lsp.servers.nil_ls")(capabilities)
require("lsp.servers.tinymist")(capabilities)

-- Enable all configured LSP servers
local enabled_servers =
	{ "lua_ls", "rust_analyzer", "tsgo", "vtsls", "vue_ls", "tailwindcss", "solargraph", "nil_ls", "tinymist" }

vim.lsp.enable(enabled_servers)
