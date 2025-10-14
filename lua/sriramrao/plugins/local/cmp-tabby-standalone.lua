-- Standalone Tabby integration for nvim-cmp
-- Usage: Just require this file after nvim-cmp is set up
-- require('your.path.to.cmp-tabby-standalone').setup(cmp)

local M = {}

-- Custom nvim-cmp source for TabbyML
local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:is_available()
  local clients = vim.lsp.get_clients({ name = 'tabby' })
  return #clients > 0
end

function source:get_debug_name()
  return 'tabby'
end

function source:get_keyword_pattern()
  return [[\w\+]]
end

function source:complete(request, callback)
  local client = vim.lsp.get_clients({ name = 'tabby' })[1]

  if not client then
    callback({ items = {}, isIncomplete = false })
    return
  end

  local params = vim.lsp.util.make_position_params(0)
  params.context = { triggerKind = 2 }

  client.request('textDocument/inlineCompletion', params, function(err, result)
    if err or not result or not result.items or #result.items == 0 then
      callback({ items = {}, isIncomplete = false })
      return
    end

    local completion_items = {}

    for _, item in ipairs(result.items) do
      local insert_text = item.insertText or ''

      if insert_text ~= '' then
        local label = insert_text:match('[^\n]*') or insert_text
        if #label > 60 then
          label = label:sub(1, 57) .. '...'
        end

        table.insert(completion_items, {
          label = label,
          kind = vim.lsp.protocol.CompletionItemKind.Snippet,
          insertText = insert_text,
          documentation = {
            kind = 'markdown',
            value = '```\n' .. insert_text .. '\n```\n\n---\n\n**Tabby AI**'
          },
          sortText = '0',
          priority = 1000,
        })
      end
    end

    callback({ items = completion_items, isIncomplete = false })
  end)
end

-- Setup function to register with cmp
function M.setup(cmp)
  cmp.register_source('cmp_tabby', source.new())
end

return M
