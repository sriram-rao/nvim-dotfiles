-- Custom blink.cmp source for TabbyML
local source = {}

function source.new(opts, config)
  opts = opts or {}
  return setmetatable({
    max_items = opts.max_items or 5,
  }, { __index = source })
end

function source:enabled()
  local clients = vim.lsp.get_clients({ name = 'tabby' })
  return #clients > 0
end

function source:get_completions(ctx, callback)
  local client = vim.lsp.get_clients({ name = 'tabby' })[1]

  if not client then
    callback({ items = {}, is_incomplete_backward = false, is_incomplete_forward = false })
    return
  end

  -- Delay the request by 200ms
  local timer = vim.loop.new_timer()
  timer:start(200, 0, vim.schedule_wrap(function()
    timer:close()

    local params = vim.lsp.util.make_position_params(0)
    params.context = {
      triggerKind = 1
    }

    client.request('textDocument/inlineCompletion', params, function(err, result)
      if err or not result or not result.items or #result.items == 0 then
        callback({ items = {}, is_incomplete_backward = false, is_incomplete_forward = false })
        return
      end

      local items = {}
      for i, item in ipairs(result.items) do
        if i > self.max_items then break end

        local insert_text = item.insertText or ''
        if insert_text ~= '' then
          -- Get the text being replaced by checking the range
          local line = vim.api.nvim_buf_get_lines(0, item.range.start.line, item.range.start.line + 1, false)[1]
          local prefix = line:sub(1, item.range.start.character)
          local label = prefix:match('%S+$') or ''

          local completion_item = {
            label = label,
            kind = vim.lsp.protocol.CompletionItemKind.Text,
            kind_name = 'Tabby',
            kind_icon = '🐈',
            textEdit = {
              newText = insert_text,
              range = item.range,
            },
            documentation = {
              kind = 'markdown',
              value = '```\n' .. insert_text .. '\n```\n\nTabby AI'
            },
          }

          table.insert(items, completion_item)
        end
      end

      callback({
        items = items,
        is_incomplete_backward = false,
        is_incomplete_forward = #result.items > self.max_items,
      })
    end)
  end))
end

return source
