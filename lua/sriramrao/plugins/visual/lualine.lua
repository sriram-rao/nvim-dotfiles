-- lua/recordline.lua
local recording_icon = ' '
local avante_statusline = require 'sriramrao.plugins.complete.avante.statusline'

local function record_status() return recording_icon end

-- Minimal provider-only indicator (with startup fallback)
local function avante_provider() return avante_statusline.provider() end

local rec_group = vim.api.nvim_create_augroup('Recordline', { clear = true })

vim.api.nvim_create_autocmd('RecordingEnter', {
  group = rec_group,
  callback = function()
    local reg = vim.fn.reg_recording()
    recording_icon = reg ~= '' and ('● @' .. reg) or '●'
    require('lualine').refresh { place = { 'statusline' } }
  end,
})

vim.api.nvim_create_autocmd('RecordingLeave', {
  group = rec_group,
  callback = function()
    recording_icon = ' '
    vim.defer_fn(
      function() require('lualine').refresh { place = { 'statusline' } } end,
      50
    )
  end,
})

return {
  'nvim-lualine/lualine.nvim',
  enabled = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- Use a single statusline across all windows/splits
    vim.o.laststatus = 3
    local lualine = require 'lualine'
    local lazy_status = require 'lazy.status' -- to configure lazy pending updates count

    local colors = {
      blue = '#65D1FF',
      green = '#3EFFDC',
      violet = '#FF61EF',
      yellow = '#FFDA7B',
      red = '#FF4A4A',
      fg = '#c3ccdc',
      bg = '#112638',
      inactive_bg = '#2c3043',
    }

    local my_lualine_theme = {
      normal = {
        a = { bg = colors.blue, fg = colors.bg, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      insert = {
        a = { bg = colors.green, fg = colors.bg, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      visual = {
        a = { bg = colors.violet, fg = colors.bg, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      command = {
        a = { bg = colors.yellow, fg = colors.bg, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      replace = {
        a = { bg = colors.red, fg = colors.bg, gui = 'bold' },
        b = { bg = colors.bg, fg = colors.fg },
        c = { bg = colors.bg, fg = colors.fg },
      },
      inactive = {
        a = { bg = colors.inactive_bg, fg = colors.semilightgray, gui = 'bold' },
        b = { bg = colors.inactive_bg, fg = colors.semilightgray },
        c = { bg = colors.inactive_bg, fg = colors.semilightgray },
      },
    }

    -- configure lualine with modified theme
    lualine.setup {
      options = {
        theme = my_lualine_theme,
        globalstatus = true,
      },
      sections = {
        -- Move Aerial next to filename on the left
        lualine_c = {
          'filename',
          {
            'aerial',
            sep = ' ) ',
            depth = nil,
            dense = false,
            dense_sep = '.',
            colored = true,
          },
        },
        lualine_x = {
          {
            record_status,
            draw_empty = true,
            padding = { left = 0, right = 1 },
            color = { fg = colors.red },
          },
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = '#ff9e64' },
          },
          {
            avante_provider,
            draw_empty = true,
            padding = { left = 1, right = 1 },
            color = { fg = colors.yellow },
          },
          -- { 'encoding' },
          { 'filetype' },
        },
      },
    }

    -- Minimal refresh so provider text reflects changes after Avante actions
    local av_grp =
      vim.api.nvim_create_augroup('LualineAvanteRefresh', { clear = true })
    vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
      group = av_grp,
      callback = function()
        pcall(
          function() require('lualine').refresh { place = { 'statusline' } } end
        )
      end,
    })
  end,
}
