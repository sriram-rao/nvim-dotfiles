return {
  'Davidyz/VectorCode',
  version = '*',
  dependencies = { 'nvim-lua/plenary.nvim' },
  build = 'uv tool upgrade vectorcode', -- Keep CLI up-to-date
  opts = {
    -- ChromaDB endpoint (running via Docker)
    server_url = 'http://localhost:8000',
  },
  config = function(_, opts)
    require('vectorcode').setup(opts)

    -- Auto-index on Neovim exit
    vim.api.nvim_create_autocmd('VimLeavePre', {
      callback = function()
        local cwd = vim.fn.getcwd()
        vim.notify('[VectorCode] Indexing ' .. cwd .. '...', vim.log.levels.INFO)
        vim.fn.jobstart({ 'vectorcode', 'vectorise', '--recursive', cwd }, {
          detach = true, -- Run in background, don't block exit
          -- Respects .gitignore by default
        })
      end,
    })
  end,
}
