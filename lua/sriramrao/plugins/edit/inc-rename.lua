-- Incremental rename
return {
  'smjonas/inc-rename.nvim',
  cmd = 'IncRename',
  config = function()
    require('inc_rename').setup()
    vim.keymap.set(
      'n',
      '<leader>lr',
      function() return ':IncRename ' .. vim.fn.expand '<cword>' end,
      { expr = true, desc = 'LSP Rename (Live)' }
    )
  end,
}
