return {
  'zbirenbaum/copilot.lua',
  enabled = false, -- Disabled in favor of Tabby
  cmd = 'Copilot',
  build = ':Copilot auth',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      suggestion = { enabled = false, auto_trigger = true },
      panel = { enabled = false },
      server_opts_overrides = {
        offset_encoding = 'utf-16',
      },
    }
  end,
}
