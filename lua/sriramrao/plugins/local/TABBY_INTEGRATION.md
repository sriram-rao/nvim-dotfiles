# Tabby AI Integration for nvim-cmp

This integration allows TabbyML completions to appear in nvim-cmp's dropdown menu.

## Files

### 1. Custom CMP Source (`cmp-tabby-source.lua`)

```lua
-- Custom nvim-cmp source for TabbyML
local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:is_available()
  -- Check if Tabby LSP client is running
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
  -- Get the Tabby LSP client
  local client = vim.lsp.get_clients({ name = 'tabby' })[1]

  if not client then
    callback({ items = {}, isIncomplete = false })
    return
  end

  -- Prepare the inline completion request
  local params = vim.lsp.util.make_position_params(0)
  params.context = {
    triggerKind = 2 -- Automatic
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

    local completion_items = {}

    for _, item in ipairs(result.items) do
      local insert_text = item.insertText or ''

      if insert_text ~= '' then
        -- Truncate label to first line for display
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

    callback({
      items = completion_items,
      isIncomplete = false
    })
  end)
end

return source
```

### 2. Tabby Plugin Config (`tabby.lua`)

```lua
return {
  'TabbyML/vim-tabby',
  enabled = true,
  lazy = false, -- Load immediately so LSP can start
  priority = 100,
  init = function()
    vim.g.tabby_agent_start_command = { 'npx', 'tabby-agent', '--stdio' }
    vim.g.tabby_keybinding_accept = '<C-y>'
    vim.g.tabby_keybinding_trigger_or_dismiss = '<C-\\>'

    -- Disable automatic inline completion (we'll use cmp instead)
    vim.g.tabby_inline_completion_trigger = 'manual'
  end,
}
```

### 3. nvim-cmp Configuration (additions)

```lua
-- In your nvim-cmp config function:

-- Register custom Tabby source
local tabby_source = require('your.path.to.cmp-tabby-source')
cmp.register_source('cmp_tabby', tabby_source.new())

cmp.setup {
  -- ... existing config ...

  window = {
    completion = cmp.config.window.bordered({
      border = 'rounded',
      winhighlight = 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None',
    }),
    documentation = cmp.config.window.bordered({
      border = 'rounded',
      winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
    }),
  },

  mapping = cmp.mapping.preset.insert {
    -- ... existing mappings ...
    ['<C-n>'] = cmp.mapping.complete(), -- Trigger all completions
    ['<C-t>'] = cmp.mapping.complete({
      config = {
        sources = {
          { name = 'cmp_tabby' }
        }
      }
    }), -- Trigger only Tabby completions
    ['<Tab>'] = cmp.mapping.confirm { select = true },
  },

  sources = cmp.config.sources {
    { name = 'cmp_tabby', priority = 1000, group_index = 1 },
    { name = 'nvim_lsp', group_index = 2 },
    { name = 'luasnip', group_index = 2 },
    { name = 'buffer', group_index = 3 },
    { name = 'path', group_index = 3 },
  },

  sorting = {
    priority_weight = 2,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },

  formatting = {
    format = function(entry, vim_item)
      -- Use lspkind for all sources first
      vim_item = lspkind.cmp_format {
        maxwidth = 50,
        ellipsis_char = '...',
      }(entry, vim_item)

      -- Customize Tabby menu
      if entry.source.name == 'cmp_tabby' then
        vim_item.menu = '🐈 [Tabby]'
      end
      return vim_item
    end,
  },
}
```

## Installation

1. Save `cmp-tabby-source.lua` somewhere in your config (e.g., `lua/plugins/local/`)
2. Update your `tabby.lua` plugin config
3. Update your `nvim-cmp.lua` config with the additions above
4. Restart Neovim

## Keybindings

- `<Tab>` - Accept completion
- `<C-n>` - Trigger all completions
- `<C-t>` - Trigger Tabby-only completions

## Features

- Multiple Tabby AI suggestions in dropdown
- Snippet icon matching other completions
- 🐈 [Tabby] label
- Horizontal separator in documentation preview
- Top priority sorting
- Rounded borders
