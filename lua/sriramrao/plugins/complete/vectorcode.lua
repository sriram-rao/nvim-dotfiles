return {
  'Davidyz/VectorCode',
  version = '*',
  dependencies = { 'nvim-lua/plenary.nvim' },
  build = 'uv tool upgrade vectorcode', -- Keep CLI up-to-date
  opts = {
    -- ChromaDB endpoint (running via Docker)
    server_url = 'http://localhost:8000',
  },
}
