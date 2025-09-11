return {
  setup = function()
    local terminal = require('toggleterm.terminal').Terminal
    local codex = terminal:new {
      cmd = 'codex',
      name = 'codex',
      hidden = true,
      direction = 'vertical',
      float_opts = {
        border = 'curved',
      },
    }

    local keymap = vim.keymap
    keymap.set(
      'n',
      '<leader>mm',
      function() codex:toggle() end,
      { desc = 'Toggle codex terminal' }
    )

    local codex_flat = terminal:new {
      cmd = 'codex',
      direction = 'horizontal',
      float_opts = {
        border = 'curved',
      },
    }
    keymap.set(
      'n',
      '<leader>mf',
      function() codex_flat:toggle() end,
      { desc = 'Toggle codex as horizontal split' }
    )
    require('toggleterm').setup {
      direction = 'vertical',
      size = vim.o.columns * 0.4,
    }
  end,
}
