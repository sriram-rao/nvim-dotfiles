return {
  'j-hui/fidget.nvim',
  opts = {
    notification = {
      window = {
        winblend = 0, -- Background opacity
        align = 'bottom', -- How to align the notification window
      },
    },
  },
  config = function(_, opts)
    require('fidget').setup(opts)

    -- Show CodeCompanion progress in fidget
    local cc_handle = nil
    vim.api.nvim_create_autocmd('User', {
      pattern = 'CodeCompanionRequest*',
      callback = function(args)
        local fidget = require('fidget')
        if args.match == 'CodeCompanionRequestStarted' then
          cc_handle = fidget.progress.handle.create({
            title = 'CodeCompanion',
            message = 'Processing...',
            lsp_client = { name = 'codecompanion' },
          })
        elseif args.match == 'CodeCompanionRequestFinished' then
          if cc_handle then
            cc_handle:finish()
            cc_handle = nil
          end
        end
      end,
    })
  end,
}
