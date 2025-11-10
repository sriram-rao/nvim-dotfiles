return {
  'nvim-tree/nvim-tree.lua',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local nvimtree = require 'nvim-tree'

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup {
      view = {
        width = 35,
        relativenumber = true,
      },
      -- change folder arrow icons
      renderer = {
        indent_markers = {
          enable = true,
        },
        icons = {
          glyphs = {
            folder = {
              arrow_closed = '', -- arrow when folder is closed
              arrow_open = '', -- arrow when folder is open
            },
          },
        },
      },
      -- disable window_picker for
      -- explorer to work well with
      -- window splits
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
      filters = {
        custom = { '.DS_Store' },
      },
      git = {
        ignore = false,
      },
    }

    -- set keymaps
    local keymap = vim.keymap -- for conciseness

    keymap.set(
      'n',
      '<leader>ed',
      '<cmd>NvimTreeToggle<CR>',
      { desc = 'explorer: toggle' }
    )
    keymap.set(
      'n',
      '<leader>ef',
      '<cmd>NvimTreeFindFileToggle<CR>',
      { desc = 'explorer: toggle on current file' }
    )
    keymap.set(
      'n',
      '<leader>ec',
      '<cmd>NvimTreeCollapse<CR>',
      { desc = 'explorer: collapse' }
    )
    keymap.set(
      'n',
      '<leader>er',
      '<cmd>NvimTreeRefresh<CR>',
      { desc = 'explorer: refresh' }
    )
    keymap.set(
      'n',
      '<leader>et',
      '<cmd>NvimTreeFocus<CR>',
      { desc = 'explorer: focus' }
    )
    keymap.set(
      'n',
      '<leader>ee',
      '<cmd>NvimTreeFindFile<CR>',
      { desc = 'explorer: find current file' }
    )
  end,
}
