local M = {}

function M.setup_rag_resource()
  local Path = require 'plenary.path'
  local curl = require 'plenary.curl'
  local cwd = vim.fn.getcwd()
  local normalized_cwd = vim.loop.fs_realpath(cwd) or Path:new(cwd):absolute()
  local rag_dir = vim.fs.joinpath(normalized_cwd, '.nvim')
  local rag_marker_path =
    Path:new(vim.fs.joinpath(rag_dir, '.avante-rag-added'))

  -- Do not create a global marker file in state/; keep marker in project .nvim only.
  local global_marker_path = nil

  local function marker_exists()
    return rag_marker_path:exists() and not rag_marker_path:is_dir()
  end

  local already_had_marker = marker_exists()

  local function to_dir_uri(path)
    if not path:match '^file://' then path = 'file://' .. path end
    if path:sub(-1) ~= '/' then path = path .. '/' end
    return path
  end

  local function create_marker_files()
    local rag_dir_path = Path:new(rag_dir)
    if not rag_dir_path:exists() then rag_dir_path:mkdir { parents = true } end
    rag_marker_path:write(normalized_cwd .. '\n', 'w')
  end

  local function normalize_uri(uri)
    if not uri or uri == '' then return '' end
    uri = uri:gsub('\n', '')
    if uri:sub(-1) ~= '/' then uri = uri .. '/' end
    return uri
  end

  local function resource_matches(resource_uri, target)
    return normalize_uri(resource_uri) == normalize_uri(target)
  end

  local function add_project_to_rag(rag_service, project_uri)
    local project_uri_in_container = rag_service.to_container_uri(project_uri)
    local resource_name = 'project-' .. vim.fn.fnamemodify(normalized_cwd, ':t')

    local ok, resources_resp = pcall(rag_service.get_resources)
    if not ok or not resources_resp then
      vim.notify(
        '[Avante RAG] Failed to get resources from service.',
        vim.log.levels.ERROR
      )
      return false
    end

    if resources_resp.resources then
      for _, resource in ipairs(resources_resp.resources) do
        if
          resource_matches(resource.uri, project_uri)
          or resource_matches(resource.uri, project_uri_in_container)
        then
          return true -- Already exists, success (silent).
        end
      end
    end
    local resp_ok, resp = pcall(
      curl.post,
      rag_service.get_rag_service_url() .. '/api/v1/add_resource',
      {
        headers = { ['Content-Type'] = 'application/json' },
        body = vim.json.encode {
          name = resource_name,
          uri = project_uri_in_container,
        },
        timeout = 30000,
      }
    )

    if not resp_ok then
      vim.notify(
        '[Avante RAG] Failed to add project: ' .. tostring(resp),
        vim.log.levels.ERROR
      )
      return false
    end

    if resp.status and resp.status >= 200 and resp.status < 300 then
      vim.notify('[Avante RAG] Project indexed successfully', vim.log.levels.INFO)
      return true
    elseif resp.status == 409 then
      return true -- Already registered (silent).
    else
      vim.notify(
        string.format('[Avante RAG] Failed to index project (status %d)', resp.status),
        vim.log.levels.ERROR
      )
      return false
    end
  end

  local function wait_for_service_and_add(retries)
    if retries <= 0 then
      vim.notify('[Avante RAG] Service not available', vim.log.levels.WARN)
      return
    end

    vim.defer_fn(function()
      local rag_service = require 'avante.rag_service'
      if not rag_service.is_ready() then
        wait_for_service_and_add(retries - 1)
        return
      end

      local project_uri = to_dir_uri(normalized_cwd)
      local ok, success = pcall(add_project_to_rag, rag_service, project_uri)

      if ok and success then
        create_marker_files()
      elseif not ok then
        vim.notify(
          '[Avante RAG] Error adding project: ' .. tostring(success),
          vim.log.levels.ERROR
        )
      end
    end, 3000)
  end

  if not already_had_marker then wait_for_service_and_add(5) end

  local rag_service = require 'avante.rag_service'
  if not rag_service._sriramrao_rag_patch then
    local original_add_resource = rag_service.add_resource
    rag_service.add_resource = function(uri)
      local target_local = normalize_uri(uri)
      local target_container = normalize_uri(rag_service.to_container_uri(uri))

      local ok, resources_resp = pcall(rag_service.get_resources)
      if ok and resources_resp and resources_resp.resources then
        for _, resource in ipairs(resources_resp.resources) do
          if
            resource_matches(resource.uri, target_local)
            or resource_matches(resource.uri, target_container)
          then
            if not marker_exists() then create_marker_files() end
            return -- Already exists (silent).
          end
        end
      end

      local result = original_add_resource(uri)
      if not marker_exists() then create_marker_files() end
      return result
    end
    rag_service._sriramrao_rag_patch = true
  end
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
      { name = 'claude-code', display = 'Claude Code (CLI)' },
      { name = 'claude', display = 'Claude Sonnet 4.5 (Paid API)' },
      { name = 'gemini-cli', display = 'Gemini (CLI)' },
      { name = 'morph', display = 'Morph v3 (Paid API)' },
      { name = 'ollama', display = 'Ollama (Local)' },
      { name = 'codex', display = 'OpenAI Codex (CLI)' },
      { name = 'openai', display = 'OpenAI GPT-5 (Paid API)' },
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

  vim.keymap.set('n', '<leader>am', function()
    local config = require 'avante.config'
    local providers_config = require 'sriramrao.plugins.complete.avante.providers'
    local current_provider = config.provider

    -- Get model names for current provider
    local provider_config = providers_config[current_provider]
    if not provider_config or not provider_config.model_names then
      vim.notify('No models available for provider: ' .. current_provider, vim.log.levels.WARN)
      return
    end

    local model_names = provider_config.model_names

    vim.ui.select(model_names, {
      prompt = string.format('Switch %s model', current_provider),
    }, function(model)
      if not model or model == '' then return end
      config.override {
        providers = {
          [current_provider] = { model = model }
        }
      }
      vim.notify(string.format('[Avante] Switched to %s', model), vim.log.levels.INFO)
      pcall(
        function() require('lualine').refresh { place = { 'statusline' } } end
      )
    end)
  end, {
    desc = 'avante: switch model for current provider',
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
