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
        -- Check for the .vectorcode marker and initialize if missing
        local uv = vim.loop
        local marker_path = vim.fn.expand '~/.vectorcode_marker'

        local function vectorcode_init()
          print 'Initializing Vectorcode environment...'
          -- Put setup logic here (create directories, files, etc.)
          -- Example: create the marker file to indicate initialization
          local fd = assert(io.open(marker_path, 'w'))
          fd:write('vectorcode initialized on ' .. os.date())
          fd:close()
          print 'Vectorcode environment initialized.'
        end

        -- Check if marker exists
        uv.fs_stat(marker_path, function(stat)
          if not stat then
            vim.schedule(vectorcode_init)
          else
            print 'Vectorcode already initialized.'
          end
        end)

        local cwd = vim.fn.getcwd()
        vim.notify(
          '[VectorCode] Indexing ' .. cwd .. '...',
          vim.log.levels.INFO
        )
        vim.fn.jobstart({ 'vectorcode', 'vectorise', '--recursive', cwd }, {
          detach = true, -- Run in background, don't block exit
          -- Respects .gitignore by default
        })
      end,

      -- Usage example:
      -- ensure_init(repo)
      -- ... rest of your code ...
    })
  end,
}
