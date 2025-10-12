-- Debug script to test Tabby cmp integration
-- Run with :luafile %

print("=== Testing Tabby CMP Integration ===")

-- Check if Tabby LSP is running
local clients = vim.lsp.get_clients({ name = 'tabby' })
print("Tabby LSP clients found: " .. #clients)

if #clients > 0 then
  print("Tabby client is running!")
  local client = clients[1]
  print("Client ID: " .. client.id)

  -- Try to make a completion request
  local params = vim.lsp.util.make_position_params()
  params.context = {
    triggerKind = 1
  }

  print("Sending textDocument/inlineCompletion request...")
  client.request('textDocument/inlineCompletion', params, function(err, result)
    if err then
      print("ERROR: " .. vim.inspect(err))
      return
    end

    if not result then
      print("No result returned")
      return
    end

    print("Result received!")
    print(vim.inspect(result))

    if result.items and #result.items > 0 then
      print("Found " .. #result.items .. " completion items")
      for i, item in ipairs(result.items) do
        print("Item " .. i .. ": " .. vim.inspect(item))
      end
    else
      print("No completion items in result")
    end
  end, 0)
else
  print("Tabby LSP client is NOT running!")
  print("Make sure vim-tabby is loaded and tabby-agent is started")
end

-- Check if cmp source is registered
local ok, cmp = pcall(require, 'cmp')
if ok then
  print("\ncmp is loaded")
  -- Try to get our source
  local sources = cmp.get_config().sources
  if sources then
    print("Configured sources:")
    for _, source_group in ipairs(sources) do
      for _, source in ipairs(source_group) do
        print("  - " .. source.name)
      end
    end
  end
else
  print("cmp is NOT loaded")
end

print("\n=== Test Complete ===")
