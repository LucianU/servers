-- General
vim.opt.number = true
vim.opt.wrap = true
vim.opt.encoding = "utf-8"
vim.opt.wildmenu = true
vim.opt.lazyredraw = true
vim.opt.ruler = true

-- Indent
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Search
vim.opt.incsearch = true
vim.opt.hlsearch = true

-- Code options
vim.opt.showmatch = true
vim.opt.colorcolumn = "101"
vim.opt.textwidth = 100
vim.opt.wrap = true

-- Suggested by nvim-tree
-- disable netrw. I don't know why, but I'm doing it
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
-- I'm curious what this does
vim.opt.termguicolors = true


vim.cmd("autocmd FileType lua set shiftwidth=2")

-- Text options
vim.cmd("autocmd FileType markdown set colorcolumn=81")
vim.cmd("autocmd FileType markdown set textwidth=80")

-- Git options
vim.cmd("autocmd FileType gitcommit set colorcolumn=73")
vim.cmd("autocmd FileType gitcommit set textwidth=72")


-- strip trailing whitespace for all files before writing
function vim.fn.stripTrailingWhitespace()
  local l = vim.fn.line(".")
  local c = vim.fn.col(".")
  vim.cmd("%s/\\s\\+$//e")
  vim.fn.cursor(l, c)
end

vim.cmd("autocmd BufWritePre * :lua vim.fn.stripTrailingWhitespace()")
-- end strip


-- Plugin Management (when used outside Nix)
local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.vim/plugged')

Plug 'maxmx03/solarized.nvim'
Plug 'itchyny/lightline.vim'             -- Status line
Plug 'junegunn/fzf'                      -- Fuzzy finder
Plug 'junegunn/fzf.vim'                 -- FZF integration
Plug 'gfanto/fzf-lsp.nvim'              -- Search for Symbols

-- File browser
Plug 'nvim-tree/nvim-tree.lua'
-- TODO: Icons are not displayed, even though I installed this plugin
-- There may be something wrong with my font. Need to investigate
Plug 'nvim-tree/nvim-web-devicons'

-- Buffers
Plug 'akinsho/bufferline.nvim'

-- Semantic highlighting
Plug 'nvim-treesitter/nvim-treesitter'

-- Language Server
Plug 'neovim/nvim-lspconfig'

-- Code complete
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'

vim.call('plug#end')
-- END Plugin Management

-- Color scheme
vim.cmd("colorscheme solarized")

-- Setup bufferline
require("bufferline").setup{}

-- Setup nvim-tree
require('nvim-tree').setup()

-- Setup nvim-treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = {
    "c", "lua", "vim", "vimdoc", "query",
    "python", "haskell", "nix", "typescript"
  },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
}

-- END Setup nvim-treesitter

-- Setup nvim-cmp
local cmp = require'cmp'

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif vim.fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends an already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
  }, {
    { name = 'buffer' },
  })
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})
-- END Setup nvim-cmp

-- Enable ruff-lsp
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig').ruff_lsp.setup{
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

-- Enable Haskell Language Server
require('lspconfig').hls.setup{
  filetypes = { 'haskell', 'lhaskell', 'cabal' },
  capabilities = capabilities
}

-- Enable Elm Language Server
require('lspconfig').elmls.setup{
  capabilities = capabilities
}

