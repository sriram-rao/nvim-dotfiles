return {
  'olimorris/codecompanion.nvim',
  config = function(_, opts)
    vim.keymap.set(
      { 'n', 'v' },
      '<C-a>',
      '<cmd>CodeCompanionActions<cr>',
      { noremap = true, silent = true }
    )
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>aa',
      '<cmd>CodeCompanionChat Toggle<cr>',
      { noremap = true, silent = true }
    )
    vim.keymap.set(
      'v',
      'ga',
      '<cmd>CodeCompanionChat Add<cr>',
      { noremap = true, silent = true }
    )

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd [[cab cc CodeCompanion]]

    require('codecompanion').setup(opts)
  end,
  opts = {
    strategies = {
      chat = {
        adapter = 'openai',
        model = 'gpt-5-mini',
      },
      inline = {
        adapter = 'openai',
        keymaps = {
          accept_change = {
            modes = { n = '<leader>ga' },
            description = 'Accept the suggested change',
          },
          reject_change = {
            modes = { n = '<leader>gr' },
            opts = { nowait = true },
            description = 'Reject the suggested change',
          },
        },
      },
    },
    display = {
      action_palette = {
        provider = 'mini_pick', -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
        opts = {
          show_default_actions = true, -- Show the default actions in the action palette?
          show_default_prompt_library = true, -- Show the default prompt library in the action palette?
          title = 'CodeCompanion actions', -- The title of the action palette
        },
      },
    },
    opts = {
      log_level = 'TRACE',
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/mcphub.nvim',
    {
      'OXY2DEV/markview.nvim',
      lazy = false,
      opts = {
        preview = {
          filetypes = { 'markdown', 'codecompanion' },
          ignore_buftypes = {},
        },
      },
    },
    {
      'echasnovski/mini.diff',
      config = function()
        local diff = require 'mini.diff'
        diff.setup {
          -- Disabled by default
          source = diff.gen_source.none(),
        }
      end,
    },
  },
  extensions = {
    mcphub = {
      callback = 'mcphub.extensions.codecompanion',
      opts = {
        make_vars = true,
        make_slash_commands = true,
        show_result_in_chat = true,
      },
    },
    vectorcode = {
      opts = {
        tool_group = {
          enabled = true,
          extras = {},
          collapse = false,
        },
        tool_opts = {
          query = {
            max_num = { chunk = -1, document = -1 },
            default_num = { chunk = 50, document = 10 },
            no_duplicate = true,
          },
        },
      },
    },
  },
}
