-- Function to load config files relative to this script's directory
local function load_config(file)
    local config_dir = vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand('<sfile>:p')), ':h')
    dofile(config_dir .. '/components/' .. file .. '.lua')
end

load_config('general')

load_config('filetype')

load_config('plug-plugins-install')

load_config('plugins-setup')

-- Language Servers
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Enable Lua Language Server
require('lspconfig').lua_ls.setup{
  capabilities = capabilities
}

-- Enable Python Language Server
require('lspconfig').pyright.setup{
  capabilities = capabilities
}

-- Enable TypeScript Language Server
require('lspconfig').tsserver.setup{
  capabilities = capabilities
}

-- Enable Nix Language Server
require('lspconfig').nil_ls.setup{
  capabilities = capabilities
}

-- Enable Nim Language Server
require('lspconfig').nim_langserver.setup{
    capabilities = capabilities
}

-- Enable Zig Language Server
require('lspconfig').zls.setup{
    capabilities = capabilities
}
-- END Language Servers

-- Project-specific Config
local project_config = vim.fn.getcwd() .. "/.nvim.lua"
if vim.fn.filereadable(project_config) == 1 then
  dofile(project_config)
end
