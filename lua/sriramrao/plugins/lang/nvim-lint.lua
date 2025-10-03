return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'

    lint.linters_by_ft = {
      javascript = { 'eslint_d' },
      typescript = { 'eslint_d' },
      javascriptreact = { 'eslint_d' },
      typescriptreact = { 'eslint_d' },
      svelte = { 'eslint_d' },
      python = { 'ruff' },
      swift = { 'swiftlint' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function() lint.try_lint() end,
    })

    vim.keymap.set(
      'n',
      '<leader>ll',
      function() lint.try_lint() end,
      { desc = 'Trigger linting for current file' }
    )

    -- Allow gf to work in winfixbuf windows and open in Snacks popup
    vim.keymap.set('n', 'gf', function()
      local file = vim.fn.expand('<cfile>')
      local snacks = require('snacks')
      
      -- Read the file into a new buffer
      local buf = vim.fn.bufadd(file)
      vim.fn.bufload(buf)
      
      snacks.win({
        buf = buf,
        width = 0.8,
        height = 0.8,
        border = 'rounded',
      })
    end, { desc = 'Go to file in popup' })
  end,
}