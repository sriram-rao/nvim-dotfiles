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
      auto_apply_diff_after_generation = false,
      minimize_diff = true,
      auto_save_before_apply = true,
    },
    provider = 'claude-code',
    mode = 'agentic',
    providers = {
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-sonnet-4-5',
        model_names = {
          'claude-sonnet-4-5',
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
        endpoint = 'https://api.morph.so/v1',
        model = 'morph-v3-large',
        model_names = {
          'morph-v3-large',
          'morph-v3-small',
        },
        api_key_name = 'MORPH_API_KEY',
        timeout = 30000,
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
      ['claude-code'] = {
        command = 'env',
        args = {
          '-u',
          'ANTHROPIC_API_KEY',
          'npx',
          '--yes',
          '@zed-industries/claude-code-acp',
        },
        env = {
          NODE_NO_WARNINGS = '1',
        },
      },
    },
    rag_service = {
      enabled = true,
      runner = 'docker', -- uses a tiny sidecar; no local LLM
      host_mount = vim.fn.expand '~/Code',
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
        '--memory=2g',
        '--memory-swap=2g',
        '--cpus=2',
        '-e DATA_DIR=/data',
        '-e IGNORE_GLOBS="target/**,**/target/**,**/node_modules/**,**/.git/**,**/dist/**,**/build/**,**/.venv/**,**/venv/**,**/.next/**,**/.svelte-kit/**,**/.turbo/**,**/*.png,**/*.jpg,**/*.pdf,**/*.zip,**/*.mp4,**/*.bin"',
        '-e INCLUDE_GLOBS="**/*.py,**/*.ts,**/*.tsx,**/*.js,**/*.lua,**/*.go,**/*.rs,**/*.md,**/*.json,**/*.toml,**/*.yml,**/*.yaml"',
        '-e TOP_K=10',
        '-e CHUNK_SIZE=700',
        '-e CHUNK_OVERLAP=80',
        '-e OPENAI_API_KEY=' .. (os.getenv 'OPENAI_API_KEY' or ''),
      }, ' '),
    },

    system_prompt = function()
      local hub = require('mcphub').get_hub_instance()
      local prompts = {}

      local hub_prompt = hub and hub:get_active_servers_prompt() or ''
      if hub_prompt ~= '' then table.insert(prompts, hub_prompt) end

      table.insert(
        prompts,
        [[Use `rag_search` whenever the task hinges on the current project’s files, history, or other locally indexed context. Prefer RAG before broader web or filesystem tools in those situations, and fall back to other tools only when RAG returns no useful sources or the task clearly needs info outside the repo.]]
      )

      return table.concat(prompts, '\n\n')
    end,
    custom_tools = function()
      return {
        require('mcphub.extensions.avante').mcp_tool(),
      }
    end,
    disabled_tools = {
      'view',
      'add_file_to_context',
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
      'add_todos',
      'update_todo_status',
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
      local nvim_dir = cwd .. '/.nvim'
      vim.fn.mkdir(nvim_dir, 'p')
      local rag_marker = nvim_dir .. '/.avante-rag-added'

      local function to_dir_uri(path)
        if not path:match '^file://' then path = 'file://' .. path end
        if path:sub(-1) ~= '/' then path = path .. '/' end
        return path
      end

      -- Check if already added for this project
      if vim.fn.filereadable(rag_marker) == 1 then return end

      -- Wait for service to be ready before checking resources
      local function wait_for_service_and_add(retries)
        if retries <= 0 then return end

        vim.defer_fn(function()
          local rag_service = require 'avante.rag_service'
          local project_uri = to_dir_uri(cwd)
          local container_uri = rag_service.to_container_uri(project_uri)
          local normalized_uris = { container_uri }

          if container_uri:sub(-1) == '/' then
            table.insert(normalized_uris, container_uri:sub(1, -2))
          else
            table.insert(normalized_uris, container_uri .. '/')
          end

          if project_uri ~= container_uri then
            table.insert(normalized_uris, project_uri)
          end
          if project_uri:sub(-1) == '/' then
            table.insert(normalized_uris, project_uri:sub(1, -2))
          end

          -- Check if service is actually responding
          local ok, resources = pcall(rag_service.get_resources)
          if not ok or not resources then
            -- Service not ready, check if container exists and restart if needed
            vim.system {
              'docker',
              'exec',
              '-d',
              'avante-rag-service',
              'sh',
              '-c',
              'pkill -f uvicorn; cd /app && python3 -m pip install -r requirements.txt >/dev/null 2>&1 && python3 -m uvicorn src.main:app --host 0.0.0.0 --port 20250',
            }
            -- Retry with longer delay after restart
            wait_for_service_and_add(retries - 1)
            return
          end

          -- Check if resource already exists
          if resources.resources then
            for _, resource in ipairs(resources.resources) do
              for _, uri in ipairs(normalized_uris) do
                if resource.uri == uri then
                  -- Resource exists, create marker
                  vim.fn.writefile({ cwd }, rag_marker)
                  return
                end
              end
            end
          end

          -- Add resource and create marker
          pcall(function()
            rag_service.add_resource(project_uri)
            vim.fn.writefile({ cwd }, rag_marker)
          end)
        end, retries == 5 and 5000 or 3000) -- First attempt waits 5s, others 3s
      end

      wait_for_service_and_add(5) -- Try 5 times
    end

    -- Setup RAG resource on startup
    setup_rag_resource()

    -- Optional debug wrapper to inspect RAG invocations
    local rag_service = require 'avante.rag_service'
    if not rag_service._debug_wrapper then
      local original_retrieve = rag_service.retrieve
      rag_service.retrieve = function(base_uri, query, on_complete)
        local function debug_message(msg, level)
          if vim.g.AVANTE_RAG_DEBUG then
            vim.notify(msg, level or vim.log.levels.INFO)
          end
        end

        debug_message(string.format('[RAG] base=%s query=%s', base_uri, query))

        -- Trim polite prefixes that LLMs sometimes prepend to rag_search queries
        local sanitized = query
          :gsub('^%s*[Uu]se rag_search to%s*', '')
          :gsub('^%s*[Pp]lease%s*', '')
        sanitized = sanitized:gsub('%s+$', '')

        return original_retrieve(base_uri, sanitized, function(resp, err)
          local count = resp and resp.sources and #resp.sources or 0
          debug_message(
            string.format(
              '[RAG] sources=%d%s',
              count,
              err and (' error: ' .. err) or ''
            ),
            err and vim.log.levels.ERROR or vim.log.levels.INFO
          )
          if on_complete then on_complete(resp, err) end
        end)
      end
      rag_service._debug_wrapper = true
    end

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
        { name = 'codex', display = 'Codex (GPT-5)' },
        { name = 'openai', display = 'OpenAI GPT' },
        { name = 'claude-code', display = 'Claude Code CLI' },
        { name = 'claude', display = 'Claude Sonnet' },
        { name = 'gemini-cli', display = 'Gemini CLI' },
        { name = 'morph', display = 'Morph v3' },
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
