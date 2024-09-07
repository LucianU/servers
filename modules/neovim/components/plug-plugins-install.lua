-- Plugin Management (when used outside Nix)
local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.vim/plugged')

Plug 'williamboman/mason.nvim'           -- Binary Manager
Plug 'williamboman/mason-lspconfig.nvim' -- Integration with lspconfig

Plug 'maxmx03/solarized.nvim'            -- Color Scheme
Plug 'itchyny/lightline.vim'             -- Status line

Plug 'junegunn/fzf'                      -- Fuzzy finder
Plug 'junegunn/fzf.vim'                  -- FZF integration
Plug 'gfanto/fzf-lsp.nvim'               -- Search for Symbols

-- File browser
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-tree.lua'

-- Buffers
Plug 'akinsho/bufferline.nvim'

-- Semantic highlighting
Plug 'nvim-treesitter/nvim-treesitter'

-- Language Server Configs
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
