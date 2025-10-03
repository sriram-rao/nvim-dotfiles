Hidden_diags = {}

local function get_project_root()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  for _, client in ipairs(clients) do
    if client.config.root_dir then return client.config.root_dir end
  end
  return vim.fn.getcwd()
end

local function get_ignore_path()
  local nvim_dir = get_project_root() .. '/.nvim'
  vim.fn.mkdir(nvim_dir, 'p')
  return nvim_dir .. '/silencio.json'
end

-- Load once on startup
local function load_ignores()
  local f = io.open(get_ignore_path(), 'r')
  if f then
    local content = f:read '*a'
    f:close()
    local ok, data = pcall(vim.fn.json_decode, content)
    if ok and type(data) == 'table' then Hidden_diags = data end
  end
end

-- Save once on exit
local function save_ignores()
  local f = io.open(get_ignore_path(), 'w')
  if f then
    f:write(vim.fn.json_encode(Hidden_diags))
    f:close()
  end
end

local function get_diagnostic_range(d)
  local s, e
  if d.user_data and d.user_data.lsp and d.user_data.lsp.range then
    s, e = d.user_data.lsp.range.start, d.user_data.lsp.range['end']
  elseif d.range then
    s, e = d.range.start, d.range['end']
  end
  return s, e
end

local function select_diagnostic_under_cursor(callback)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line, col = cursor[1] - 1, cursor[2]

  local choices = {}

  for _, d in ipairs(vim.diagnostic.get(bufnr)) do
    local s, e = get_diagnostic_range(d)
    if
      s
      and e
      and s.line == line
      and s.character <= col
      and col <= e.character
    then
      local lsp = d.user_data and d.user_data.lsp or d
      if lsp.code then
        table.insert(choices, {
          label = lsp.message:gsub('\n', ' ') .. ' (' .. lsp.code .. ')',
          code = lsp.code,
          source = lsp.source,
        })
      end
    end
  end

  if #choices == 0 then
    print 'No diagnostics with codes under cursor'
    return
  end

  vim.ui.select(choices, {
    prompt = 'Ignore which diagnostic code?',
    format_item = function(item) return item.label end,
  }, function(choice)
    if choice then callback(choice.code) end
  end)
end

load_ignores()

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = save_ignores,
})

vim.keymap.set('n', '<leader>si', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line, col = cursor[1] - 1, cursor[2]

  for _, d in ipairs(vim.diagnostic.get(bufnr)) do
    local s, e = get_diagnostic_range(d)
    if
      s
      and e
      and s.line == line
      and s.character <= col
      and col <= e.character
    then
      local uri = vim.uri_from_bufnr(bufnr)
      local pos_key =
        string.format('%d:%d:%d:%d', s.line, s.character, e.line, e.character)

      Hidden_diags[uri] = Hidden_diags[uri] or {}
      Hidden_diags[uri][pos_key] = true
      vim.cmd 'write'
    end
  end
end)

vim.keymap.set('n', '<leader>sR', function()
  Hidden_diags = {}
  vim.cmd 'write'
end, { desc = 'Restore all hidden diagnostics' })

vim.keymap.set('n', '<leader>sr', function()
  local uri = vim.uri_from_bufnr(0)
  Hidden_diags[uri] = nil
  vim.cmd 'write'
end, { desc = 'Restore hidden diagnostics for this file' })

vim.keymap.set('n', '<leader>sc', function()
  local uri = vim.uri_from_bufnr(0)
  select_diagnostic_under_cursor(function(code)
    Hidden_diags[uri] = Hidden_diags[uri] or {}
    Hidden_diags[uri]._codes = Hidden_diags[uri]._codes or {}
    Hidden_diags[uri]._codes[code] = true
    vim.cmd 'write'
    print("Ignored code '" .. code .. "' in this file.")
  end)
end)

vim.keymap.set('n', '<leader>sC', function()
  select_diagnostic_under_cursor(function(code)
    Hidden_diags._project_codes = Hidden_diags._project_codes or {}
    Hidden_diags._project_codes[code] = true
    vim.cmd 'write'
    print("Ignored code '" .. code .. "' project-wide.")
  end)
end)

vim.lsp.handlers['textDocument/publishDiagnostics'] = function(
  _,
  result,
  ctx,
  config
)
  if not result then return end

  local uri = result.uri
  local file_ignores = Hidden_diags[uri] or {}

  local ignored_codes = file_ignores._codes or {}

  local project_ignored = Hidden_diags._project_codes or {}
  result.diagnostics = vim.tbl_filter(function(d)
    if d.code and (ignored_codes[d.code] or project_ignored[d.code]) then
      return false
    end
    local s, e = get_diagnostic_range(d)
    if s and e then
      local pos_key =
        string.format('%d:%d:%d:%d', s.line, s.character, e.line, e.character)
      return not file_ignores[pos_key]
    end
    return true
  end, result.diagnostics)

  vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
end
