return {
  'akinsho/toggleterm.nvim',
  config = function()
    local keymap = vim.keymap
    keymap.set(
      'n',
      '<leader>tt',
      '<cmd>ToggleTerm direction=horizontal size=10<CR>',
      { desc = 'Toggle terminal' }
    )
    keymap.set(
      'n',
      '<leader>th',
      '<cmd>ToggleTerm direction=horizontal<CR>',
      { desc = 'Toggle terminal as horizontal split' }
    )
    keymap.set(
      'n',
      '<leader>tf',
      '<cmd>ToggleTerm direction=float<CR>',
      { desc = 'Toggle floating terminal' }
    )
    keymap.set(
      'n',
      '<leader>tv',
      '<cmd>ToggleTerm direction=vertical<CR>',
      { desc = 'Toggle terminal as vertical split' }
    )
    -- keymap.set('n', '<leader>tn', '<cmd>TermNew<CR>', { desc = 'New terminal' })
    keymap.set(
      'n',
      '<leader>ts',
      '<cmd>TermSelect<CR>',
      { desc = 'Select terminal' }
    )
    require('toggleterm').setup {
      direction = 'horizontal',
    }
  end,
}
