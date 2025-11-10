return {
  'ravitemer/mcphub.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  build = 'npm install -g mcp-hub@latest', -- Installs `mcp-hub` node binary globally
  config = function()
    require('mcphub').setup {
      workspace = {
        enabled = true,
        reload_on_dir_changed = true, -- Auto-reload hub when directory changes
      },
    }
  end,
}
