-- Dynamic model storage (module-level, accessible by adapter functions)
local runtime_models = {
  anthropic = 'claude-sonnet-4-5-20250929',
  openai = 'gpt-5-mini',
  ollama = 'llama3.1:8b', -- Best tool support + reasonable memory
}

return {
  'olimorris/codecompanion.nvim',
  config = function(_, opts)
    local codecompanion_current_opts = opts -- keep for resetting
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
      { noremap = true, silent = true, desc = 'codecompanion: toggle chat' }
    )
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>an',
      '<cmd>CodeCompanionChat<cr>',
      { noremap = true, silent = true, desc = 'codecompanion: new chat' }
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

    -- patch centered_picker_config into mini_pick window opts at runtime
    if
      opts.display
      and opts.display.action_palette
      and opts.display.action_palette.opts
    then
      opts.display.action_palette.opts.window =
        { config = centered_picker_config }
    end
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

    -- Model list (ollama alphabetically sorted, others by priority)
    local models = {
      anthropic = {
        'claude-sonnet-4-5-20250929',
        'claude-opus-4-20250514',
        'claude-3-5-sonnet-20241022',
      },
      openai = {
        'gpt-5-mini',
        'gpt-5',
        'gpt-4o',
        'gpt-4o-mini',
        'o1-preview',
      },
      ollama = {
        'deepseek-r1:1.5b', -- Lightweight reasoning, ~1 GB
        'deepseek-r1:7b', -- Strong reasoning for code, ~5 GB
        'gemma3:1b', -- Ultra lightweight, ~800 MB
        'gemma3:4b', -- General purpose, ~3 GB
        'gpt-oss:120b-cloud', -- Free cloud model, no local storage
        'llama3.1:8b', -- Best tool support, ~5 GB, 128K context
        'qwen2.5-coder:1.5b', -- Lightweight code specialist, ~1 GB
      },
    }

    -- Function to set provider and model
    local function set_provider_and_model(provider, model)
      -- Update runtime model storage
      if
        runtime_models[provider] ~= nil
        or provider == 'anthropic'
        or provider == 'ollama'
      then
        runtime_models[provider] = model
      end

      -- Update the original opts table
      codecompanion_current_opts.strategies.chat.adapter = provider
      codecompanion_current_opts.strategies.chat.model = model

      -- Re-setup with the original opts (adapter functions will now read from runtime_models)
      local ok, cc = pcall(require, 'codecompanion')
      if ok then cc.setup(codecompanion_current_opts) end

      vim.notify(
        string.format(
          '[CodeCompanion] Provider set to %s, Model set to %s',
          provider,
          model
        ),
        vim.log.levels.INFO
      )
      vim.cmd 'redrawstatus' -- update statusline (heirline)
    end

    -- Provider picker (alphabetically sorted)
    local providers = {
      { name = 'anthropic', display = 'Anthropic Claude' },
      { name = 'claude_code', display = 'Claude Code (CLI)' },
      { name = 'gemini_cli', display = 'Gemini (CLI)' },
      { name = 'ollama', display = 'Ollama' },
      { name = 'openai', display = 'OpenAI' },
    }

    vim.keymap.set('n', '<leader>ap', function()
      require('mini.pick').start {
        source = {
          items = providers,
          name = 'CodeCompanion Provider',
          choose = function(item)
            if not item then return end
            local default_model = (models[item.name] and models[item.name][1])
              or nil
            set_provider_and_model(item.name, default_model)
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

    -- Model picker (logic only, definition moved above)

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
            local cur_config = require 'codecompanion.config'
            local cur_provider = cur_config.strategies.chat.adapter
            set_provider_and_model(cur_provider, model)
          end,
        },
        options = { window = { config = centered_picker_config } },
      }
    end, { desc = 'codecompanion: pick model', silent = true })
  end,
  opts = {
    system_prompt = function(opts)
      return opts.system_prompt
        .. '\n\nRead guidelines in agents.md. Be concise and direct. Assume presence of tools and use them wherever you can. Use @{vectorcode_tools} for repository context.'
    end,
    adapters = {
      http = {
        anthropic = function()
          return require('codecompanion.adapters').extend('anthropic', {
            schema = {
              model = {
                default = runtime_models.anthropic
                  or 'claude-sonnet-4-5-20250929',
              },
            },
          })
        end,
        ollama = function()
          return require('codecompanion.adapters').extend('ollama', {
            schema = {
              model = {
                default = runtime_models.ollama or 'llama3.1:8b',
              },
              num_ctx = {
                -- DeepSeek uses 4K context to save memory (6.5GB vs 13GB with 16K)
                default = (runtime_models.ollama or 'llama3.1:8b'):match 'deepseek'
                    and 4096
                  or 16384,
              },
            },
          })
        end,
      },
      acp = {
        claude_code = function()
          return require('codecompanion.adapters').extend('claude_code', {
            commands = {
              default = {
                'env',
                '-u',
                'ANTHROPIC_API_KEY',
                'npx',
                '--yes',
                '@zed-industries/claude-code-acp',
              },
            },
            env = {
              CLAUDE_CODE_OAUTH_TOKEN = 'CLAUDE_CODE_OAUTH_TOKEN',
            },
          })
        end,
        gemini_cli = function()
          return require('codecompanion.adapters').extend('gemini_cli', {
            commands = {
              default = {
                'gemini',
                '--experimental-acp',
              },
            },
            defaults = {
              auth_method = 'gemini-api-key', -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
            },
            env = {
              GEMINI_API_KEY = os.getenv 'GEMINI_API_KEY', -- or os.getenv("GEMINI_API_KEY")
            },
          })
        end,
        codex_cli = function()
          return require('codecompanion.adapters').extend('codex_cli', {
            commands = {
              default = {
                'npx',
                '@zed-industries/codex-acp',
              },
            },
            env = {
              OPENAI_API_KEY = 'OPENAI_API_KEY',
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
          -- window config for mini_pick inserted at runtime due to scoping
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
