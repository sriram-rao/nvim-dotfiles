return {
  'b0o/incline.nvim',
  event = 'BufReadPre',
  priority = 1200,
  config = function()
    local filetype_colors = {
      lua = { bg = '#51A0CF', fg = '#011628' },
      python = { bg = '#3572A5', fg = '#CBE0F0' },
      javascript = { bg = '#F1E05A', fg = '#011628' },
      typescript = { bg = '#2B7489', fg = '#CBE0F0' },
      rust = { bg = '#DEA584', fg = '#011628' },
      go = { bg = '#00ADD8', fg = '#011628' },
      html = { bg = '#E34C26', fg = '#CBE0F0' },
      css = { bg = '#563D7C', fg = '#CBE0F0' },
      markdown = { bg = '#083FA1', fg = '#CBE0F0' },
      vim = { bg = '#199F4B', fg = '#011628' },
      c = { bg = '#555555', fg = '#CBE0F0' },
      cpp = { bg = '#F34B7D', fg = '#011628' },
      java = { bg = '#B07219', fg = '#011628' },
      json = { bg = '#292929', fg = '#CBE0F0' },
      yaml = { bg = '#CB171E', fg = '#CBE0F0' },
    }

    require('incline').setup {
      window = { margin = { vertical = 0, horizontal = 1 } },
      hide = {
        cursorline = true,
      },
      render = function(props)
        local filename =
          vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if vim.bo[props.buf].modified then filename = '[+] ' .. filename end

        local icon = require('nvim-web-devicons').get_icon(filename)

        local ft = vim.bo[props.buf].filetype
        local colors = filetype_colors[ft] or { bg = '#143652', fg = '#CBE0F0' }

        return {
          { icon, guifg = '#CBE0F0' },  -- Always visible white/light color
          { ' ' },
          { ' ' .. filename .. ' ', guibg = colors.bg, guifg = colors.fg }
        }
      end,
    }
  end,
}
