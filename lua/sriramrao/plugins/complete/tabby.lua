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
    vim.g.tabby_inline_completion_keybinding_accept = '<leader>ay'
    vim.g.tabby_inline_completion_keybinding_trigger_or_dismiss = ''
    vim.g.tabby_inline_completion_trigger = 'manual'
  end,
  config = function()
    require('tabby.lsp.nvim_lsp').setup()

    local function toggle_inline()
      local next_state = vim.g.tabby_inline_completion_trigger == 'auto' and 'manual' or 'auto'
      vim.g.tabby_inline_completion_trigger = next_state
      if next_state == 'manual' then
        pcall(vim.fn['tabby#inline_completion#service#TriggerOrDismiss'])
      end
      vim.notify('[Tabby] Inline ghost text: ' .. (next_state == 'auto' and 'enabled' or 'disabled'), vim.log.levels.INFO)
    end

    vim.keymap.set('n', '<C-\\>', toggle_inline, { desc = 'tabby: toggle ghost text' })
    vim.keymap.set('i', '<C-\\>', function()
      toggle_inline()
      return ''
    end, { desc = 'tabby: toggle ghost text', expr = true })

    vim.keymap.set('i', '<leader>ai', function()
      local ok, result = pcall(vim.fn['tabby#inline_completion#service#TriggerOrDismiss'])
      return ok and result or ''
    end, { desc = 'tabby: inline once', expr = true })
  end,
}
