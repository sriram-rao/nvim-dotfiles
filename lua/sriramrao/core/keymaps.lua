vim.g.mapleader = ' '
vim.g.maplocalleader = ','

local keymap = vim.keymap

keymap.set('n', '<leader>nh', ':nohl<CR>', { desc = 'Clear search highlights' })

keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'window: split vertically' })
keymap.set('n', '<leader>wh', '<C-w>s', { desc = 'window: split horizontally' })
keymap.set('n', '<leader>ws', '<C-w>=', { desc = 'window: make splits equal size' })
keymap.set(
  'n',
  '<leader>wx',
  '<cmd>close<CR>',
  { desc = 'window: close current split' }
)

keymap.set('n', '<leader>to', '<cmd>tabnew<CR>', { desc = 'tab: open new' })
keymap.set(
  'n',
  '<leader>tx',
  '<cmd>tabclose<CR>',
  { desc = 'tab: close current' }
)
keymap.set('n', '<leader>tn', '<cmd>tabn<CR>', { desc = 'tab: go to next' })
keymap.set('n', '<leader>tp', '<cmd>tabp<CR>', { desc = 'tab: go to previous' })
keymap.set(
  'n',
  '<leader>tf',
  '<cmd>tabnew %<CR>',
  { desc = 'tab: open current buffer in new tab' }
)

keymap.set(
  'n',
  '<leader>wh',
  '<C-w><C-h>',
  { desc = 'window: move focus left' }
)
keymap.set(
  'n',
  '<leader>wi',
  '<C-w><C-l>',
  { desc = 'window: move focus right' }
)
keymap.set(
  'n',
  '<leader>wn',
  '<C-w><C-j>',
  { desc = 'window: move focus down' }
)
keymap.set(
  'n',
  '<leader>we',
  '<C-w><C-k>',
  { desc = 'window: move focus up' }
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
