vim.cmd 'let g:netrw_liststyle = 3'

local opt = vim.opt

opt.relativenumber = true
opt.number = true -- shows absolute line number on current cursor line

opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 2
opt.expandtab = true
opt.autoindent = true
opt.breakindent = true

opt.wrap = false

opt.ignorecase = true
opt.smartcase = true

opt.cursorline = true

opt.undofile = true

opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

opt.inccommand = 'split'

opt.clipboard:append 'unnamedplus'

opt.splitright = true
opt.splitbelow = true

-- appearance
opt.termguicolors = true -- will only work in a true color terminal
opt.background = 'dark'
opt.signcolumn = 'yes'

vim.g.have_nerd_font = true

opt.scrolloff = 10
