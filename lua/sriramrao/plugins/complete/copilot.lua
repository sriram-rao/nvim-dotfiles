return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  build = ':Copilot auth',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = { enabled = false, auto_trigger = true },
      panel = { enabled = false },
    }
  end,
}
