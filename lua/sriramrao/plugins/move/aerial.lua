return {
  'stevearc/aerial.nvim',
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('aerial').setup {
      backends = { 'treesitter', 'lsp', 'markdown' },
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set(
          'n',
          '[a',
          '<cmd>AerialPrev<CR>',
          { buffer = bufnr, desc = 'Aerial: previous symbol' }
        )
        vim.keymap.set(
          'n',
          ']a',
          '<cmd>AerialNext<CR>',
          { buffer = bufnr, desc = 'Aerial: next symbol' }
        )
      end,
    }
    -- You probably also want to set a keymap to toggle aerial
    vim.keymap.set(
      'n',
      '<leader>a',
      '<cmd>AerialToggle!<CR>',
      { desc = 'Toggle aerial' }
    )

    require('aerial').snacks_picker {
      layout = {
        preset = 'dropdown',
        preview = false,
      },
    }
    require('telescope').setup {
      extensions = {
        aerial = {
          -- Set the width of the first two columns (the second
          -- is relevant only when show_columns is set to 'both')
          col1_width = 4,
          col2_width = 30,
          -- How to format the symbols
          format_symbol = function(symbol_path, filetype)
            if filetype == 'json' or filetype == 'yaml' then
              return table.concat(symbol_path, '.')
            else
              return symbol_path[#symbol_path]
            end
          end,
          -- Available modes: symbols, lines, both
          show_columns = 'both',
        },
      },
    }
    require('telescope').load_extension 'aerial'

    require('lualine').setup {
      sections = {
        lualine_x = { 'aerial' },

        -- Or you can customize it
        lualine_y = {
          {
            'aerial',
            sep = ' ) ',
            depth = nil,
            dense = false,
            dense_sep = '.',
            colored = true,
          },
        },
      },
    }
  end,
}
