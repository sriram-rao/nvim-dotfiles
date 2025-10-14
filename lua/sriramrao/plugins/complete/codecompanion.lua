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
      { 'n', 'v' },
      '<leader>an',
      '<cmd>CodeCompanionChat<cr>',
      { noremap = true, silent = true }
    )
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>ae',
      '<cmd>CodeCompanion<cr>',
      { noremap = true, silent = true, desc = 'codecompanion: inline edit' }
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

    -- Toggle auto-add buffer to context
    vim.api.nvim_create_user_command(
      'CodeCompanionToggleAutoContext',
      function()
        local config = require 'codecompanion.config'
        local current = config.strategies.chat.auto_submit_context.buffer
        config.strategies.chat.auto_submit_context.buffer = not current
        local status = config.strategies.chat.auto_submit_context.buffer
            and 'enabled'
          or 'disabled'
        vim.notify(
          '[CodeCompanion] Auto-add buffer to context: ' .. status,
          vim.log.levels.INFO
        )
      end,
      { desc = 'Toggle auto-add buffer to CodeCompanion context' }
    )

    -- Keymap to toggle auto-add buffer
    vim.keymap.set(
      'n',
      '<leader>at',
      '<cmd>CodeCompanionToggleAutoContext<cr>',
      {
        desc = 'codecompanion: toggle auto-add buffer',
        silent = true,
      }
    )

    -- Centered picker window config
    local centered_picker_config = function()
      local height = math.floor(0.3 * vim.o.lines)
      local width = math.floor(0.4 * vim.o.columns)
      return {
        anchor = 'NW',
        height = height,
        width = width,
        row = math.floor(0.5 * (vim.o.lines - height)),
        col = math.floor(0.5 * (vim.o.columns - width)),
        border = 'rounded',
      }
    end

    -- Provider picker
    local providers = {
      { name = 'anthropic', display = 'Claude Sonnet 4.5 (API)' },
      { name = 'claude_code', display = 'Claude Code (CLI)' },
      { name = 'gemini_cli', display = 'Gemini (CLI)' },
      { name = 'ollama', display = 'Ollama Llama 3.1' },
      { name = 'openai', display = 'OpenAI GPT-5 Mini' },
    }

    vim.keymap.set('n', '<leader>ap', function()
      require('mini.pick').start {
        source = {
          items = providers,
          name = 'CodeCompanion Provider',
          choose = function(item)
            if not item then return end
            require('codecompanion.config').strategies.chat.adapter = item.name
            vim.notify(
              '[CodeCompanion] → ' .. item.display,
              vim.log.levels.INFO
            )
          end,
          show = function(buf_id, items)
            local lines = vim.tbl_map(
              function(item) return item.display end,
              items
            )
            vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
          end,
        },
        options = { window = { config = centered_picker_config } },
      }
    end, { desc = 'codecompanion: pick provider', silent = true })

    -- Model picker
    local models = {
      anthropic = {
        'claude-sonnet-4-5-20250929',
        'claude-opus-4-20250514',
        'claude-3-5-sonnet-20241022',
      },
      openai = {
        'gpt-5-mini',
        'gpt-4o',
        'gpt-4-turbo',
        'o1-preview',
      },
      ollama = {
        'llama3.1:8b',
        'llama3.1:70b',
        'codellama:13b',
        'deepseek-coder:6.7b',
      },
    }

    vim.keymap.set('n', '<leader>am', function()
      local config = require 'codecompanion.config'
      local provider = config.strategies.chat.adapter
      local available = models[provider]

      if not available or #available == 0 then
        vim.notify(
          '[CodeCompanion] No models for ' .. provider,
          vim.log.levels.WARN
        )
        return
      end

      require('mini.pick').start {
        source = {
          items = available,
          name = 'CodeCompanion Model (' .. provider .. ')',
          choose = function(model)
            if not model then return end
            -- Update chat strategy model
            config.strategies.chat.model = model
            vim.notify('[CodeCompanion] → ' .. model, vim.log.levels.INFO)
          end,
        },
        options = { window = { config = centered_picker_config } },
      }
    end, { desc = 'codecompanion: pick model', silent = true })
  end,
  opts = {
    system_prompt = function(opts)
      return opts.system_prompt
        .. '\n\nBe concise and direct in your responses. Avoid unnecessary explanation. Use tools wherever you can, including vectorcode as RAG'
    end,
    adapters = {
      http = {
        anthropic = function()
          return require('codecompanion.adapters').extend('anthropic', {
            schema = {
              model = {
                default = 'claude-sonnet-4-5-20250929',
              },
            },
          })
        end,
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            schema = {
              model = {
                default = 'llama3.1:8b',
              },
              num_ctx = {
                default = 16384,
              },
            },
          })
        end,
      },
      acp = {
        claude_code = function()
          return require('codecompanion.adapters').extend('claude_code', {
            env = {
              CLAUDE_CODE_OAUTH_TOKEN = 'CLAUDE_CODE_OAUTH_TOKEN',
            },
          })
        end,
        codex = function()
          return {
            name = 'codex',
            type = 'acp',
            formatted_name = 'OpenAI Codex',
            commands = {
              default = {
                'codex-acp',
              },
            },
            defaults = {
              auth_method = 'oauth-personal',
              mcpServers = {},
              timeout = 20000,
            },
            roles = {
              llm = 'assistant',
              user = 'user',
            },
          }
        end,
        gemini_cli = function()
          return require('codecompanion.adapters').extend('gemini_cli', {
            defaults = {
              auth_method = 'gemini-api-key', -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
            },
            env = {
              GEMINI_API_KEY = os.getenv 'GEMINI_API_KEY', -- or os.getenv("GEMINI_API_KEY")
            },
          })
        end,
      },
    },
    strategies = {
      chat = {
        adapter = 'openai',
        model = 'gpt-5-mini',
        opts = {
          completion_provider = 'blink', -- Use nvim-cmp in chat buffer
        },
        auto_submit_context = {
          buffer = true, -- Auto-add current buffer to context
        },
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
          window = { config = centered_picker_config },
        },
      },
    },
    opts = {
      log_level = 'TRACE',
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
            ['*'] = {}, -- Default settings for all tools
            ls = {},
            vectorise = {},
            query = {
              max_num = { chunk = -1, document = -1 },
              default_num = { chunk = 50, document = 10 },
              include_stderr = false,
              use_lsp = false,
              no_duplicate = true,
              chunk_mode = false,
              summarise = {
                enabled = false,
                adapter = nil,
                query_augmented = true,
              },
            },
            files_ls = {},
            files_rm = {},
          },
          prompt_library = {
            -- Example: custom project-specific prompts
            -- ['Neovim Tutor'] = {
            --   project_root = vim.env.VIMRUNTIME,
            --   file_patterns = { 'lua/**/**.lua', 'doc/**/**.txt' },
            -- },
          },
        },
      },
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/mcphub.nvim',
    'Davidyz/VectorCode',
    'echasnovski/mini.pick',
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
}
