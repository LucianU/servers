-- Disable providers
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

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

-- strip trailing whitespace for all files before writing
function vim.fn.stripTrailingWhitespace()
  local l = vim.fn.line(".")
  local c = vim.fn.col(".")
  vim.cmd("%s/\\s\\+$//e")
  vim.fn.cursor(l, c)
end

vim.cmd("autocmd BufWritePre * :lua vim.fn.stripTrailingWhitespace()")
-- end strip

