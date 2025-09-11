-- Incremental rename
return {
  'smjonas/inc-rename.nvim',
  cmd = 'IncRename',
  config = function()
    print 'Loading incremental rename plugin...'
    require('inc_rename').setup()
    vim.keymap.set(
      'n',
      '<leader>rqqr',
      function() return ':IncRename ' .. vim.fn.expand '<cword>' end,
      { expr = true, desc = 'LSP Rename (Live)' }
    )
  end,
}
