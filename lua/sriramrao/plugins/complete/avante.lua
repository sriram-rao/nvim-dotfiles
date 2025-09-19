return {
  'yetone/avante.nvim',
  -- ⚠️ must add this setting! ! !
  build = 'make',
  event = 'VeryLazy',
  version = false, -- Never set this value to "*"! Never!
  opts = {
    instructions_file = 'AGENTS.md',
    behaviour = {
      enable_fastapply = true,
      auto_apply_diff_after_generation = true,
      minimize_diff = true,
    },
    provider = 'openai',
    mode = 'legacy',
    providers = {
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-sonnet-4-20250514',
        model_names = {
          'claude-sonnet-4-20250514',
          'claude-3-7-sonnet-20250219',
          'claude-3-5-sonnet-20241022',
        },
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          max_tokens = 32768,
        },
      },
      openai = {
        endpoint = 'https://api.openai.com/v1',
        model = 'gpt-5',
        model_names = {
          'gpt-5',
          'gpt-4.1',
          'o4-mini',
          'gpt-4o',
        },
        timeout = 30000, -- Timeout in milliseconds
        extra_request_body = {
          temperature = 1,
          reasoning_effort = 'low',
        },
      },
      morph = {
        model = 'morph-v3-large',
        model_names = {
          'morph-v3-large',
          'morph-v3-small',
        },
      },
    },
    web_search_engine = {
      provider = 'google',
      proxy = nil,
    },
    acp_providers = {
      ['gemini-cli'] = {
        command = 'gemini',
        args = { '--experimental-acp' },
        env = {
          NODE_NO_WARNINGS = '1',
          GEMINI_API_KEY = os.getenv 'GEMINI_API_KEY',
        },
      },
      ['claude-cli'] = {
        command = 'npx',
        args = { '@zed-industries/claude-code-acp' },
        env = {
          NODE_NO_WARNINGS = '1',
          ANTHROPIC_API_KEY = os.getenv 'ANTHROPIC_API_KEY',
        },
      },
    },
    system_prompt = function()
      local hub = require('mcphub').get_hub_instance()
      return hub and hub:get_active_servers_prompt() or ''
    end,
    custom_tools = function()
      return {
        require('mcphub.extensions.avante').mcp_tool(),
      }
    end,
    disabled_tools = {
      'list_files', -- built-in file operations
      'search_files',
      'read_file',
      'create_file',
      'rename_file',
      'delete_file',
      'create_dir',
      'rename_dir',
      'delete_dir',
      'bash', -- built-in terminal access
    },
    windows = {
      edit = { border = 'rounded' },
      ask = { border = 'rounded' },
      sidebar_header = { enabled = true, align = 'center', rounded = true },
    },
    -- Split-based UI: separators are styled via colorscheme config
  },
  config = function(_, opts)
    local avante = require 'avante'

    avante.setup(opts)

    ---@param provider string
    local function apply_provider_choice(provider)
      local config = require 'avante.config'
      local is_acp = config.acp_providers
        and config.acp_providers[provider] ~= nil

      if is_acp then
        config.override { provider = provider }
      else
        vim.cmd('AvanteSwitchProvider ' .. provider)
      end

      pcall(
        function() require('lualine').refresh { place = { 'statusline' } } end
      )
    end

    vim.keymap.set('n', '<leader>al', function()
      local choices = {
        { name = 'openai', display = 'OpenAI GPT' },
        { name = 'claude-cli', display = 'Claude Code CLI' },
        { name = 'claude', display = 'Claude Sonnet' },
        { name = 'gemini-cli', display = 'Gemini CLI' },
      }

      vim.ui.select(choices, {
        prompt = 'Switch avante provider',
        format_item = function(item) return item.display end,
      }, function(choice)
        if not choice or choice.name == '' then return end
        apply_provider_choice(choice.name)
      end)
    end, {
      desc = 'avante: list providers',
      silent = true,
    })

    -- Event-based: refresh when window focus changes
    local grp =
      vim.api.nvim_create_augroup('AvanteLualineRefresh', { clear = true })
    vim.api.nvim_create_autocmd({ 'WinEnter', 'FocusGained' }, {
      group = grp,
      callback = function()
        pcall(
          function() require('lualine').refresh { place = { 'statusline' } } end
        )
      end,
    })
  end,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    'echasnovski/mini.pick', -- for file_selector provider mini.pick
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    'ibhagwan/fzf-lua', -- for file_selector provider fzf
    'stevearc/dressing.nvim', -- for input provider dressing
    'folke/snacks.nvim', -- for input provider snacks
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    'zbirenbaum/copilot.lua', -- for providers='copilot'
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
        },
      },
    },
  },
}
