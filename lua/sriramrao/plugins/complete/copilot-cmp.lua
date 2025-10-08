return {
  'zbirenbaum/copilot-cmp',
  enabled = false, -- Disabled in favor of Tabby
  dependencies = { 'zbirenbaum/copilot.lua' },
  config = function() require('copilot_cmp').setup() end,
}
