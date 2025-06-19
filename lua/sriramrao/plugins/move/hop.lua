return {
  'smoka7/hop.nvim',
  version = '*',
  opts = {
    keys = 'etovxqpdygfblzhckisuran',
  },
  config = function()
    -- place this in one of your configuration file(s)
    local hop = require 'hop'
    hop.setup {
      hint_position = require('hop.hint').HintPosition.END,
      multi_windows = true,
    }

    vim.keymap.set('n', '<leader>hw', hop.hint_words, { desc = 'Hop to word' })
    vim.keymap.set(
      'n',
      '<leader>ha',
      hop.hint_char1,
      { desc = 'Hop to this char' }
    )
    vim.keymap.set(
      'n',
      '<leader>hc',
      hop.hint_char2,
      { desc = 'Hop to these chars (maximum 2)' }
    )
    vim.keymap.set(
      'n',
      '<leader>hl',
      hop.hint_lines_skip_whitespace,
      { desc = 'Hop to start of line' }
    )
    vim.keymap.set(
      'n',
      '<leader>hp',
      hop.hint_patterns,
      { desc = 'Hop to pattern' }
    )
  end,
}
