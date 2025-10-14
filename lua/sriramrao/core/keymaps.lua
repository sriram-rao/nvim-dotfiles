vim.g.mapleader = ' '
vim.g.maplocalleader = ','

local keymap = vim.keymap

keymap.set('n', '<leader>nh', ':nohl<CR>', { desc = 'Clear search highlights' })

keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
keymap.set('n', '<leader>wh', '<C-w>s', { desc = 'Split window horizontally' })
keymap.set('n', '<leader>ws', '<C-w>=', { desc = 'Make splits equal size' })
keymap.set(
  'n',
  '<leader>wx',
  '<cmd>close<CR>',
  { desc = 'Close current split' }
)

keymap.set('n', '<leader>to', '<cmd>tabnew<CR>', { desc = 'Open new tab' })
keymap.set(
  'n',
  '<leader>tx',
  '<cmd>tabclose<CR>',
  { desc = 'Close current tab' }
)
keymap.set('n', '<leader>tn', '<cmd>tabn<CR>', { desc = 'Go to next tab' })
keymap.set('n', '<leader>tp', '<cmd>tabp<CR>', { desc = 'Go to previous tab' })
keymap.set(
  'n',
  '<leader>tf',
  '<cmd>tabnew %<CR>',
  { desc = 'Open current buffer (e.g. file) in a new tab' }
)

keymap.set(
  'n',
  '<leader>wh',
  '<C-w><C-h>',
  { desc = 'Move focus to the left window' }
)
keymap.set(
  'n',
  '<leader>wi',
  '<C-w><C-l>',
  { desc = 'Move focus to the right window' }
)
keymap.set(
  'n',
  '<leader>wn',
  '<C-w><C-j>',
  { desc = 'Move focus to the lower window' }
)
keymap.set(
  'n',
  '<leader>we',
  '<C-w><C-k>',
  { desc = 'Move focus to the upper window' }
)

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = 'term://*',
  callback = set_terminal_keymaps,
})
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup(
    'kickstart-highlight-yank',
    { clear = true }
  ),
  callback = function() vim.highlight.on_yank() end,
})
