local M = {}

function M.setup_rag_resource()
  local cwd = vim.fn.getcwd()
  local nvim_dir = cwd .. '/.nvim'
  vim.fn.mkdir(nvim_dir, 'p')
  local rag_marker = nvim_dir .. '/.avante-rag-added'

  local function to_dir_uri(path)
    if not path:match '^file://' then path = 'file://' .. path end
    if path:sub(-1) ~= '/' then path = path .. '/' end
    return path
  end

  if vim.fn.filereadable(rag_marker) == 1 then return end

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

      local ok, resources = pcall(rag_service.get_resources)
      if not ok or not resources then
        vim.system {
          'docker',
          'exec',
          '-d',
          'avante-rag-service',
          'sh',
          '-c',
          'pkill -f uvicorn; cd /app && python3 -m pip install -r requirements.txt >/dev/null 2>&1 && python3 -m uvicorn src.main:app --host 0.0.0.0 --port 20250',
        }
        wait_for_service_and_add(retries - 1)
        return
      end

      if resources.resources then
        for _, resource in ipairs(resources.resources) do
          for _, uri in ipairs(normalized_uris) do
            if resource.uri == uri then
              vim.fn.writefile({ cwd }, rag_marker)
              return
            end
          end
        end
      end

      pcall(function()
        rag_service.add_resource(project_uri)
        vim.fn.writefile({ cwd }, rag_marker)
      end)
    end, retries == 5 and 5000 or 3000)
  end

  wait_for_service_and_add(5)
end

function M.setup_rag_debug()
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
end

function M.setup_provider_switcher()
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
      { name = 'openai', display = 'OpenAI GPT-5 mini' },
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
end

return M
