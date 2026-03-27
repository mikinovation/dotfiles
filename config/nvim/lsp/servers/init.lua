-- lsp/servers/init.lua

-- capabilities - integration with nvim-cmp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Load each server configuration
require("lsp.servers.lua_ls")(capabilities)
require("lsp.servers.rust_analyzer")(capabilities)
require("lsp.servers.typescript")(capabilities)
require("lsp.servers.tailwindcss")(capabilities)
require("lsp.servers.solargraph")(capabilities)

-- Enable all configured LSP servers
local enabled_servers = { "lua_ls", "rust_analyzer", "tsgo", "vtsls", "vue_ls", "tailwindcss", "solargraph" }

vim.lsp.enable(enabled_servers)
