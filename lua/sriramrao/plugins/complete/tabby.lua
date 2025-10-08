return {
  'TabbyML/vim-tabby',
  event = 'InsertEnter',
  config = function()
    -- Server endpoint is configured in ~/.tabby-client/agent/config.toml
    vim.g.tabby_agent_start_command = { 'npx', 'tabby-agent', '--stdio' }

    -- Optional: Configure keymaps (changed to avoid conflict with nvim-cmp)
    vim.g.tabby_keybinding_accept = '<C-y>'  -- Ctrl+y to accept Tabby
    vim.g.tabby_keybinding_trigger_or_dismiss = '<C-\\>'
  end,
}
