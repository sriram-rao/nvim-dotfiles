return {
  'stevearc/aerial.nvim',
  keys = {
    {
      '<leader>aa',
      '<cmd>AerialToggle!<CR>',
      desc = 'Aerial toggle',
    },
    {
      '<leader>ap',
      function()
        require('aerial').snacks_picker {
          layout = {
            preset = 'dropdown',
            preview = false,
          },
        }
      end,
      desc = 'Aerial picker',
    },
  },
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    require('aerial').setup {
      backends = { 'treesitter', 'lsp', 'markdown' },
      lazy_load = true, -- load aerial only when needed
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
    }
    -- You probably also want to set a keymap to toggle aerial
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
