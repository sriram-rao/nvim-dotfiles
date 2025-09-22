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
opt.wrap = true
opt.linebreak = true

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
opt.winborder = 'single'

vim.g.have_nerd_font = true

opt.scrolloff = 10

vim.diagnostic.config {
  virtual_text = {
    spacing = 2,
    prefix = '', -- or "" if you want it super clean
    severity = {
      min = vim.diagnostic.severity.ERROR,
      max = vim.diagnostic.severity.ERROR,
    },
  },
  signs = true, -- shows signs in gutter
  underline = true,
  update_in_insert = false,
  severity_sort = true,
}
