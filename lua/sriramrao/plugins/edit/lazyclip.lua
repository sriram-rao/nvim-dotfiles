return {
  'atiladefreitas/lazyclip',
  config = function()
    vim.keymap.del('n', '<leader>Cw') -- remove hardcoded mapping
    require('lazyclip').setup {
      -- your custom config here (optional)
      vim.keymap.set(
        'n',
        '<leader>cc',
        ":lua require('lazyclip.ui').open_window()<CR>",
        { desc = 'Open clipboard manager' }
      ),
    }
  end,
  event = { 'InsertEnter' },
}
