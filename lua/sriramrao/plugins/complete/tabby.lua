return {
  'TabbyML/vim-tabby',
  enabled = true,
  lazy = false, -- Load immediately so LSP can start
  priority = 100, -- Load early
  dependencies = {
    'neovim/nvim-lspconfig',
  },
  init = function()
    -- Set config before plugin loads
    vim.g.tabby_agent_start_command = { 'npx', 'tabby-agent', '--stdio' }
    vim.g.tabby_keybinding_accept = '<C-y>' -- Ctrl+y to accept Tabby
    vim.g.tabby_keybinding_trigger_or_dismiss = '<C-\\>'

    -- Disable automatic inline completion (we'll use cmp instead)
    vim.g.tabby_inline_completion_trigger = 'manual'
  end,
  config = function()
    -- Setup Tabby LSP client so it can be used by blink.cmp
    require('tabby.lsp.nvim_lsp').setup()
  end,
}
