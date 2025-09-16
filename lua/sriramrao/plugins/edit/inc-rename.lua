-- Incremental rename
return {
  'smjonas/inc-rename.nvim',
  cmd = 'IncRename',
  event = { 'BufReadPre', 'BufNewFile' },
  opts = {},
  config = function(_, opts)
    require('inc_rename').setup(opts)
    vim.keymap.set(
      'n',
      ',r',
      function() return ':IncRename ' .. vim.fn.expand '<cword>' end,
      { expr = true, desc = 'Incremental rename' }
    )
  end,
}
