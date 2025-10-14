-- Custom nvim-cmp source for TabbyML
local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:is_available()
  -- Always return true for testing
  print("cmp_tabby is_available called, returning TRUE")
  return true
  -- Check if Tabby LSP client is running
  -- local clients = vim.lsp.get_clients({ name = 'tabby' })
  -- return #clients > 0
end

function source:get_debug_name()
  return 'tabby'
end

function source:get_keyword_pattern()
  return [[\w\+]]
end

function source:complete(request, callback)
  print("========== TABBY SOURCE COMPLETE CALLED ==========")
  -- Get the Tabby LSP client
  local client = vim.lsp.get_clients({ name = 'tabby' })[1]
  print("Tabby client found:", client ~= nil)

  if not client then
    callback({ items = {}, isIncomplete = false })
    return
  end

  local cmp = require('cmp')

  -- Prepare the inline completion request
  local params = vim.lsp.util.make_position_params(0) -- 0 for current buffer
  params.context = {
    triggerKind = 2 -- Automatic (1 = Invoked, 2 = Automatic)
  }

  -- Request inline completion from Tabby
  client.request('textDocument/inlineCompletion', params, function(err, result)
    if err then
      callback({ items = {}, isIncomplete = false })
      return
    end

    if not result or not result.items or #result.items == 0 then
      callback({ items = {}, isIncomplete = false })
      return
    end

    -- Tabby returns inline completion items
    local completion_items = {}

    for _, item in ipairs(result.items) do
      local insert_text = item.insertText or ''

      -- Only show if there's actual text to insert
      if insert_text ~= '' then
        -- Truncate label to first line for display
        local label = insert_text:match('[^\n]*') or insert_text
        if #label > 60 then
          label = label:sub(1, 57) .. '...'
        end

        table.insert(completion_items, {
          word = insert_text,
          label = "XXXXXXX " .. label, -- OBVIOUS MARKER
          kind = 15, -- Hardcode Snippet kind
          data = {
            snippet_text = insert_text
          },
          documentation = {
            kind = 'markdown',
            value = '```\n' .. insert_text .. '\n```\n\n---\n\n**Tabby AI**'
          },
          sortText = '0',
          priority = 1000,
        })
      end
    end

    callback({
      items = completion_items,
      isIncomplete = false
    })
  end)
end

return source
