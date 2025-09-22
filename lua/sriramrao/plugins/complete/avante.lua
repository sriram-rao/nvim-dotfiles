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
    provider = 'claude',
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
          -- tool_choice = 'auto', -- critical
          -- parallel_tool_calls = true,
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
    rag_service = {
      enabled = true,
      runner = 'docker', -- uses a tiny sidecar; no local LLM
      host_mount = vim.fn.getcwd(), -- project root only
      llm = {
        provider = 'openai',
        endpoint = 'https://api.openai.com/v1',
        api_key = 'OPENAI_API_KEY',
        model = 'gpt-4o-mini',
      },
      embed = {
        provider = 'openai',
        endpoint = 'https://api.openai.com/v1',
        api_key = 'OPENAI_API_KEY',
        model = 'text-embedding-3-small',
      },
      docker_extra_args = table.concat({
        '--memory=1g',
        '--memory-swap=1g',
        '--cpus=1',
        '-e DATA_DIR=/data',
        '-e IGNORE_GLOBS="**/node_modules/**,**/.git/**,**/dist/**,**/build/**,**/.venv/**,**/venv/**,**/target/**,**/*.png,**/*.jpg,**/*.pdf,**/*.zip,**/*.mp4,**/*.bin"',
        '-e INCLUDE_GLOBS="**/*.py,**/*.ts,**/*.tsx,**/*.js,**/*.lua,**/*.go,**/*.rs,**/*.md,**/*.json,**/*.toml,**/*.yml,**/*.yaml"',
        '-e TOP_K=10',
        '-e CHUNK_SIZE=700',
        '-e CHUNK_OVERLAP=80',
        '-e OPENAI_API_KEY=' .. (os.getenv 'OPENAI_API_KEY' or ''),
      }, ' '),
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

    -- Auto-add current directory to RAG service once per project
    local function setup_rag_resource()
      local cwd = vim.fn.getcwd()
      local rag_marker = cwd .. '/.avante-rag-added'

      -- Check if already added for this project
      if vim.fn.filereadable(rag_marker) == 1 then return end

      -- Wait for service to be ready before checking resources
      local function wait_for_service_and_add(retries)
        if retries <= 0 then return end

        vim.defer_fn(function()
          local rag_service = require 'avante.rag_service'

          -- Check if service is actually responding
          local ok, resources = pcall(rag_service.get_resources)
          if not ok or not resources then
            -- Service not ready, retry
            wait_for_service_and_add(retries - 1)
            return
          end

          -- Check if resource already exists
          if resources.resources then
            for _, resource in ipairs(resources.resources) do
              if
                resource.uri == 'file://' .. cwd
                or resource.uri == 'file:///host'
              then
                -- Resource exists, create marker
                vim.fn.writefile({ cwd }, rag_marker)
                return
              end
            end
          end

          -- Add resource and create marker
          pcall(function()
            rag_service.add_resource(cwd)
            vim.fn.writefile({ cwd }, rag_marker)
          end)
        end, 3000)
      end

      wait_for_service_and_add(5) -- Try 5 times
    end

    -- Setup RAG resource on startup
    setup_rag_resource()

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
